from typing import Optional

import json

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.recycler import Recycler

router = APIRouter(prefix="/api/recyclers", tags=["recyclers"])


@router.get("/")
def list_recyclers(db: Session = Depends(get_db)):
    """List all recyclers."""
    recyclers = db.query(Recycler).all()
    return [_recycler_to_response(r) for r in recyclers]


@router.get("/matches")
def get_matches(lot_id: str = Query(...), db: Session = Depends(get_db)):
    """Get matched recyclers for a lot, ranked by compatibility."""
    from app.services.recycler_matcher import match

    return match(db, lot_id)


def _recycler_to_response(r) -> dict:
    materials = []
    rates = {}
    try:
        materials = json.loads(r.materials_accepted) if r.materials_accepted else []
    except (json.JSONDecodeError, TypeError):
        pass
    try:
        rates = json.loads(r.offered_rates) if r.offered_rates else {}
    except (json.JSONDecodeError, TypeError):
        pass

    return {
        "id": r.id,
        "user_id": r.user_id,
        "name": r.name,
        "facility_location": r.facility_location,
        "latitude": r.latitude,
        "longitude": r.longitude,
        "materials_accepted": materials,
        "authorization_status": r.authorization_status,
        "authorization_reference": r.authorization_reference,
        "contact": r.contact,
        "offered_rates": rates,
        "pickup_available": r.pickup_available,
        "service_radius_km": r.service_radius_km,
    }
