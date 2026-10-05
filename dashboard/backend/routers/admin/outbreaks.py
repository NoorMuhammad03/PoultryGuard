# Admin outbreaks endpoints with PostGIS geofencing.
# Endpoints from PoultryGuard_Dashboard_Architecture.md Section 7:
# - GET /admin/outbreaks — outbreak heatmap with 15km radius circles

from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import func, text
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from datetime import datetime, timedelta

from auth.role_guard import require_admin
from models.user import User
from models.outbreak_alert import OutbreakAlert, OutbreakSeverity
from models.farm import Farm
from db.postgres import get_db

router = APIRouter(prefix="/api/v1/admin", tags=["admin", "outbreaks"])


def format_outbreak(outbreak: OutbreakAlert, farm: Farm = None) -> dict:
    """Format an outbreak for API response."""
    return {
        "id": outbreak.id,
        "farm_id": outbreak.farm_id,
        "farm_name": farm.name if farm else None,
        "disease": outbreak.disease,
        "severity": outbreak.severity.value,
        "location_lat": outbreak.location_lat,
        "location_lng": outbreak.location_lng,
        "radius_km": outbreak.radius_km,
        "bird_count_affected": outbreak.bird_count_affected,
        "description": outbreak.description,
        "reported_at": outbreak.reported_at.isoformat(),
        "resolved_at": outbreak.resolved_at.isoformat() if outbreak.resolved_at else None,
    }


@router.get("/outbreaks")
async def get_outbreaks(
    days: int = Query(30, ge=1, le=365, description="Lookback window in days"),
    severity: Optional[str] = Query(None, description="Filter by severity"),
    disease: Optional[str] = Query(None, description="Filter by disease"),
    limit: int = Query(50, ge=1, le=100, description="Max outbreaks to return"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/outbreaks — Outbreak heatmap data with 15km radius circles.
    Optimized: Eager-loads Farm relation via joinedload to eliminate N+1 queries.
    Enforces require_admin security and supports pagination.
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    query = db.query(OutbreakAlert).options(joinedload(OutbreakAlert.farm)).filter(OutbreakAlert.reported_at >= start_date)

    if severity:
        if severity not in [s.value for s in OutbreakSeverity]:
            raise HTTPException(status_code=400, detail=f"Invalid severity: {severity}")
        query = query.filter(OutbreakAlert.severity == OutbreakSeverity(severity))

    if disease:
        query = query.filter(OutbreakAlert.disease.ilike(f"%{disease}%"))

    outbreaks = (
        query.order_by(OutbreakAlert.reported_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    return [format_outbreak(o, o.farm) for o in outbreaks]


@router.get("/outbreaks/geofence")
async def get_outbreaks_geofence(
    lat: float = Query(..., description="Center latitude"),
    lng: float = Query(..., description="Center longitude"),
    radius_km: float = Query(15, ge=1, le=100, description="Search radius in km"),
    days: int = Query(30, ge=1, le=365),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/outbreaks/geofence — Find outbreaks within a geofenced radius.

    Uses PostGIS ST_DWithin for accurate geodesic distance (if PostGIS available).
    Falls back to Haversine formula for SQLite/dev environments.
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    # Try PostGIS first (production), fallback to raw SQL for dev
    try:
        # PostGIS query using geography type
        from sqlalchemy import text
        sql = text("""
            SELECT oa.*, f.name as farm_name
            FROM outbreak_alerts oa
            JOIN farms f ON oa.farm_id = f.id
            WHERE oa.reported_at >= :start_date
            AND ST_DWithin(
                oa.location::geography,
                ST_MakePoint(:lng, :lat)::geography,
                :radius_meters
            )
            ORDER BY oa.reported_at DESC
        """)
        result = db.execute(sql, {
            "start_date": start_date,
            "lat": lat,
            "lng": lng,
            "radius_meters": radius_km * 1000,
        }).fetchall()

        return [
            {
                "id": r.id,
                "farm_id": r.farm_id,
                "farm_name": r.farm_name,
                "disease": r.disease,
                "severity": r.severity,
                "location_lat": r.location_lat,
                "location_lng": r.location_lng,
                "radius_km": r.radius_km,
                "bird_count_affected": r.bird_count_affected,
                "description": r.description,
                "reported_at": r.reported_at.isoformat() if r.reported_at else None,
            }
            for r in result
        ]
    except Exception:
        # Fallback: Haversine formula for SQLite/dev
        from math import radians, sin, cos, sqrt, atan2

        def haversine(lat1, lon1, lat2, lon2):
            R = 6371  # Earth radius in km
            dlat = radians(lat2 - lat1)
            dlon = radians(lon2 - lon1)
            a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
            return 2 * R * atan2(sqrt(a), sqrt(1-a))

        query = db.query(OutbreakAlert, Farm).join(
            Farm, OutbreakAlert.farm_id == Farm.id
        ).filter(
            OutbreakAlert.reported_at >= start_date,
            OutbreakAlert.location_lat.isnot(None),
            OutbreakAlert.location_lng.isnot(None),
        )

        results = query.all()
        filtered = []
        for outbreak, farm in results:
            dist = haversine(lat, lng, outbreak.location_lat, outbreak.location_lng)
            if dist <= radius_km:
                filtered.append(format_outbreak(outbreak, farm))

        return filtered


@router.get("/outbreaks/nearby-farms")
async def get_nearby_farms_for_outbreak(
    outbreak_id: int = Query(..., description="Outbreak ID to find nearby farms"),
    radius_km: float = Query(15, ge=1, le=100),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/outbreaks/nearby-farms — Find farms within 15km of an outbreak.

    Used for community disease notification (Section 6.8).
    Returns farms that should receive alerts for a given outbreak.
    """
    outbreak = db.query(OutbreakAlert).filter(OutbreakAlert.id == outbreak_id).first()
    if not outbreak:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail=f"Outbreak {outbreak_id} not found")

    if not outbreak.location_lat or not outbreak.location_lng:
        return []

    # Use same logic as geofence endpoint
    try:
        from sqlalchemy import text
        sql = text("""
            SELECT f.*, ST_Distance(
                ST_MakePoint(:lng, :lat)::geography,
                ST_MakePoint(f.location_lng, f.location_lat)::geography
            ) / 1000 as distance_km
            FROM farms f
            WHERE f.location_lat IS NOT NULL
            AND f.location_lng IS NOT NULL
            AND ST_DWithin(
                ST_MakePoint(f.location_lng, f.location_lat)::geography,
                ST_MakePoint(:lng, :lat)::geography,
                :radius_meters
            )
            ORDER BY distance_km
        """)
        result = db.execute(sql, {
            "lat": outbreak.location_lat,
            "lng": outbreak.location_lng,
            "radius_meters": radius_km * 1000,
        }).fetchall()

        return [
            {
                "id": r.id,
                "name": r.name,
                "owner_id": r.owner_id,
                "location_lat": r.location_lat,
                "location_lng": r.location_lng,
                "status": r.status.value if r.status else "safe",
                "distance_km": round(r.distance_km, 2),
            }
            for r in result
        ]
    except Exception:
        # Fallback: Haversine
        from math import radians, sin, cos, sqrt, atan2

        def haversine(lat1, lon1, lat2, lon2):
            R = 6371
            dlat = radians(lat2 - lat1)
            dlon = radians(lon2 - lon1)
            a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
            return 2 * R * atan2(sqrt(a), sqrt(1-a))

        farms = db.query(Farm).filter(
            Farm.location_lat.isnot(None),
            Farm.location_lng.isnot(None),
        ).all()

        nearby = []
        for farm in farms:
            dist = haversine(
                outbreak.location_lat, outbreak.location_lng,
                farm.location_lat, farm.location_lng
            )
            if dist <= radius_km:
                nearby.append({
                    "id": farm.id,
                    "name": farm.name,
                    "owner_id": farm.owner_id,
                    "location_lat": farm.location_lat,
                    "location_lng": farm.location_lng,
                    "status": farm.status.value if farm.status else "safe",
                    "distance_km": round(dist, 2),
                })

        nearby.sort(key=lambda x: x["distance_km"])
        return nearby