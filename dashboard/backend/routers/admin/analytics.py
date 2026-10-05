# Admin analytics endpoints — real data from PostgreSQL.
# Endpoints from PoultryGuard_Dashboard_Architecture.md Section 7:
# - GET /admin/analytics/diagnoses — diagnosis counts by disease type
# - GET /admin/analytics/model — model accuracy metrics

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, distinct, case
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta

from auth.role_guard import require_admin
from models.user import User
from models.diagnosis import Diagnosis, DiseaseType, ModelInferenceLog
from db.postgres import get_db

router = APIRouter(prefix="/api/v1/admin", tags=["admin", "analytics"])


@router.get("/analytics/diagnoses")
async def get_diagnoses_analytics(
    days: int = Query(7, ge=1, le=90, description="Number of days to look back"),
    disease: Optional[str] = Query(None, description="Filter by disease type"),
    farm_id: Optional[int] = Query(None, description="Filter by farm"),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/analytics/diagnoses — Daily diagnosis counts by disease type.
    Used for dashboard charts and reports.

    Query params:
    - days: lookback window (default 7)
    - disease: filter by disease type (coccidiosis, newcastle, salmonellosis)
    - farm_id: filter by specific farm
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    query = db.query(
        func.date(Diagnosis.diagnosed_at).label("date"),
        Diagnosis.disease_type,
        func.count(Diagnosis.id).label("count"),
    ).filter(Diagnosis.diagnosed_at >= start_date)

    if disease:
        if disease not in [d.value for d in DiseaseType]:
            from fastapi import HTTPException
            raise HTTPException(status_code=400, detail=f"Invalid disease: {disease}")
        query = query.filter(Diagnosis.disease_type == DiseaseType(disease))

    if farm_id:
        query = query.filter(Diagnosis.farm_id == farm_id)

    query = query.group_by(
        func.date(Diagnosis.diagnosed_at),
        Diagnosis.disease_type,
    ).order_by(func.date(Diagnosis.diagnosed_at), Diagnosis.disease_type)

    results = query.all()

    # Format for frontend: [{date, disease_type, count}, ...]
    return [
        {
            "date": str(r.date),
            "disease_type": r.disease_type.value,
            "count": r.count,
        }
        for r in results
    ]


@router.get("/analytics/diagnoses/summary")
async def get_diagnoses_summary(
    days: int = Query(7, ge=1, le=365),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/analytics/diagnoses/summary — Total counts by disease type.
    Used for KPI cards and pie charts.
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    results = db.query(
        Diagnosis.disease_type,
        func.count(Diagnosis.id).label("total"),
        func.avg(Diagnosis.confidence).label("avg_confidence"),
    ).filter(Diagnosis.diagnosed_at >= start_date).group_by(Diagnosis.disease_type).all()

    return [
        {
            "disease_type": r.disease_type.value,
            "total": r.total,
            "avg_confidence": round(float(r.avg_confidence), 4) if r.avg_confidence else 0,
        }
        for r in results
    ]


@router.get("/analytics/model")
async def get_model_analytics(
    days: int = Query(7, ge=1, le=90, description="Number of days to look back"),
    disease: Optional[str] = Query(None, description="Filter by disease type"),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/analytics/model — Per-disease accuracy metrics over time.
    Used for model performance monitoring.

    Accuracy = correct_predictions / total_predictions_with_feedback
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    query = db.query(
        func.date(ModelInferenceLog.inferred_at).label("date"),
        ModelInferenceLog.disease_type,
        func.count(ModelInferenceLog.id).label("total_inferences"),
        func.sum(
            case((ModelInferenceLog.is_correct == True, 1), else_=0)
        ).label("correct_predictions"),
    ).filter(
        ModelInferenceLog.inferred_at >= start_date,
        ModelInferenceLog.is_correct.isnot(None),  # Only count inferences with feedback
    )

    if disease:
        if disease not in [d.value for d in DiseaseType]:
            from fastapi import HTTPException
            raise HTTPException(status_code=400, detail=f"Invalid disease: {disease}")
        query = query.filter(ModelInferenceLog.disease_type == DiseaseType(disease))

    query = query.group_by(
        func.date(ModelInferenceLog.inferred_at),
        ModelInferenceLog.disease_type,
    ).order_by(func.date(ModelInferenceLog.inferred_at), ModelInferenceLog.disease_type)

    results = query.all()

    return [
        {
            "date": str(r.date),
            "disease": r.disease_type.value,
            "accuracy": round(r.correct_predictions / r.total_inferences, 4) if r.total_inferences > 0 else 0,
            "total_inferences": r.total_inferences,
            "correct_predictions": r.correct_predictions,
        }
        for r in results
    ]


@router.get("/analytics/model/summary")
async def get_model_summary(
    days: int = Query(30, ge=1, le=365),
    user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    GET /admin/analytics/model/summary — Overall accuracy per disease.
    Used for KPI cards and bar charts.
    """
    start_date = datetime.utcnow() - timedelta(days=days)

    results = db.query(
        ModelInferenceLog.disease_type,
        func.count(ModelInferenceLog.id).label("total_inferences"),
        func.sum(
            case((ModelInferenceLog.is_correct == True, 1), else_=0)
        ).label("correct_predictions"),
        func.avg(ModelInferenceLog.confidence).label("avg_confidence"),
    ).filter(
        ModelInferenceLog.inferred_at >= start_date,
        ModelInferenceLog.is_correct.isnot(None),
    ).group_by(ModelInferenceLog.disease_type).all()

    return [
        {
            "disease": r.disease_type.value,
            "accuracy": round(r.correct_predictions / r.total_inferences, 4) if r.total_inferences > 0 else 0,
            "total_inferences": r.total_inferences,
            "correct_predictions": r.correct_predictions,
            "avg_confidence": round(float(r.avg_confidence), 4) if r.avg_confidence else 0,
        }
        for r in results
    ]