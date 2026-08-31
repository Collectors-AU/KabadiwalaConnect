from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.traceability import TraceabilityEvent
from app.models.lot import Lot

router = APIRouter()

@router.get("/{lot_id}")
def get_material_passport(lot_id: str, db: Session = Depends(get_db)):
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")
        
    events = db.query(TraceabilityEvent).filter(TraceabilityEvent.lot_id == lot_id).order_by(TraceabilityEvent.timestamp).all()
    
    return {
        "lot_id": lot.id,
        "status": lot.status,
        "events": events
    }
