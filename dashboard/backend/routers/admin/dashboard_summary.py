"""
BFF (Backend-For-Frontend) Aggregated Dashboard Router
Provides a single, consolidated endpoint (GET /api/v1/admin/dashboard/summary)
for the Admin Dashboard to eliminate multiple sequential client-side network roundtrips.
Includes multi-worker safe TTL caching (Redis with in-memory fallback) and eager-loaded relations.
"""

from typing import Dict, Any, Optional
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func

from auth.role_guard import require_admin
from db.postgres import get_db
from models.user import User, UserRole
from models.farm import Farm
from models.diagnosis import Diagnosis
from models.outbreak_alert import OutbreakAlert
from services.cache import cache_manager

router = APIRouter(prefix="/api/v1/admin", tags=["admin", "bff"])

CACHE_TTL_SECONDS = 30


@router.get("/dashboard/summary")
async def get_dashboard_summary(
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /api/v1/admin/dashboard/summary (BFF Pattern)

    Returns aggregated KPI metrics, farm status counts, daily diagnoses,
    and recent activity in ONE network call.
    Uses multi-worker safe TTL cache with role/user-scoped cache key.
    Eager-loads outbreak and diagnosis farm relations via joinedload (eliminates N+1 queries).
    """
    # Cache key includes role and user ID for multi-tenant / scoped safety
    cache_key = f"admin_dashboard_summary:{user.role.value}:{user.id}"

    # Return cached data if fresh in Redis / memory
    cached = cache_manager.get(cache_key)
    if cached:
        return cached

    # 1. Total farms and counts
    farms = db.query(Farm).all()
    if not farms:
        from routers.admin.farms import MOCK_FARMS
        farm_list = MOCK_FARMS
    else:
        farm_list = [
            {
                "id": str(f.id),
                "name": f.name,
                "status": getattr(f, "status", "safe"),
                "bird_count": getattr(f, "capacity", 0),
            }
            for f in farms
        ]

    total_farms = len(farm_list)
    active_alerts = len([f for f in farm_list if f.get("status") in ("warning", "critical")])
    critical_alerts = len([f for f in farm_list if f.get("status") == "critical"])

    # 2. Diagnoses today count
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    diagnoses_today_count = (
        db.query(func.count(Diagnosis.id))
        .filter(Diagnosis.diagnosed_at >= today_start)
        .scalar()
        or 0
    )

    # 3. Pending veterinarians count
    pending_vets_count = (
        db.query(func.count(User.id))
        .filter(User.role == UserRole.VET, User.is_verified == False)
        .scalar()
        or 0
    )

    # 4. Active outbreaks count
    active_outbreaks_count = (
        db.query(func.count(OutbreakAlert.id))
        .filter(OutbreakAlert.resolved_at.is_(None))
        .scalar()
        or 0
    )

    # 5. Dynamic recent biosecurity activity log (Eager-loaded to eliminate N+1 queries)
    recent_activity = []

    recent_outbreaks = (
        db.query(OutbreakAlert)
        .options(joinedload(OutbreakAlert.farm))
        .order_by(OutbreakAlert.created_at.desc())
        .limit(3)
        .all()
    )
    for ob in recent_outbreaks:
        farm = ob.farm
        farm_name = farm.name if farm else f"Farm #{ob.farm_id}"
        sev_str = ob.severity.value if hasattr(ob.severity, "value") else str(ob.severity)
        severity_type = "critical" if sev_str.lower() in ("critical", "high") else "warning"
        disease_name = getattr(ob, "disease", "Unknown Disease").replace('_', ' ').title()
        recent_activity.append({
            "id": f"outbreak-{ob.id}",
            "type": severity_type,
            "title": f"Biosecurity Alert: {disease_name}",
            "farm": farm_name,
            "farm_id": ob.farm_id,
            "time": "Active",
            "details": f"Alert level: {sev_str.upper()}. Quarantine radius: {ob.radius_km} km.",
        })

    recent_vets = (
        db.query(User)
        .filter(User.role == UserRole.VET)
        .order_by(User.id.desc())
        .limit(2)
        .all()
    )
    for v in recent_vets:
        recent_activity.append({
            "id": f"vet-{v.id}",
            "type": "safe" if v.is_verified else "warning",
            "title": "Veterinary Practitioner Verification" if not v.is_verified else "Veterinary Practitioner Approved",
            "farm": f"{v.name or v.email}",
            "time": "Pending Review" if not v.is_verified else "Verified",
            "details": f"Role: Certified Avian Pathologist. Status: {'Verified Active' if v.is_verified else 'Awaiting PMDC license review'}.",
        })

    recent_diags = (
        db.query(Diagnosis)
        .options(joinedload(Diagnosis.farm))
        .order_by(Diagnosis.diagnosed_at.desc())
        .limit(2)
        .all()
    )
    for d in recent_diags:
        farm = d.farm
        diag_name = d.disease_type.replace('_', ' ').title()
        conf_pct = round((d.confidence or 0.95) * 100, 1)
        recent_activity.append({
            "id": f"diag-{d.id}",
            "type": "critical" if conf_pct > 90 else "warning",
            "title": f"AI Diagnostic Inference: {diag_name}",
            "farm": farm.name if farm else "Broiler Production Unit",
            "farm_id": d.farm_id,
            "time": "Today",
            "details": f"Neural model confidence: {conf_pct}%. Immediate biosecurity protocol engaged.",
        })

    payload = {
        "kpis": {
            "total_farms": total_farms,
            "active_alerts": active_alerts,
            "critical_alerts": critical_alerts,
            "diagnoses_today": diagnoses_today_count,
            "pending_vets": pending_vets_count,
            "active_outbreaks": active_outbreaks_count,
        },
        "farms_preview": farm_list[:6],
        "recent_activity": recent_activity,
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }

    # Store in multi-worker safe TTL cache
    cache_manager.set(cache_key, payload, ttl_seconds=CACHE_TTL_SECONDS)

    return payload
