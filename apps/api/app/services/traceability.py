from typing import Optional

"""Traceability service for material passports."""
import uuid
import json
from datetime import datetime
from sqlalchemy.orm import Session
from app.models.traceability import TraceabilityEvent
from app.models.lot import Lot
from app.models.user import User
from app.models.material import MaterialCategory

def add_event(
    db: Session,
    lot_id: str,
    event_type: str,
    actor_id: str,
    location: Optional[str] = None,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    photo_url: Optional[str] = None,
    reference_number: Optional[str] = None,
    metadata: dict | None = None,
) -> TraceabilityEvent:
    """Add a traceability event for a lot."""
    event = TraceabilityEvent(
        id=str(uuid.uuid4()),
        lot_id=lot_id,
        event_type=event_type,
        location=location,
        latitude=latitude,
        longitude=longitude,
        timestamp=datetime.utcnow(),
        photo_url=photo_url,
        actor_id=actor_id,
        reference_number=reference_number,
        metadata=json.dumps(metadata or {}),
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event

def get_passport(db: Session, lot_id: str) -> dict | None:
    """
    Build a material passport for a lot.
    
    A material passport is the complete chain of custody and processing
    events for a lot of e-waste material.
    """
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        return None
    
    material = db.query(MaterialCategory).filter(MaterialCategory.id == lot.material_category_id).first()
    collector = db.query(User).filter(User.id == lot.collector_id).first()
    
    events = db.query(TraceabilityEvent).filter(
        TraceabilityEvent.lot_id == lot_id
    ).order_by(TraceabilityEvent.timestamp.asc()).all()
    
    event_list = []
    for event in events:
        meta = {}
        try:
            meta = json.loads(event.metadata) if event.metadata else {}
        except (json.JSONDecodeError, TypeError):
            pass
        
        event_list.append({
            "id": event.id,
            "lot_id": event.lot_id,
            "event_type": event.event_type,
            "location": event.location,
            "latitude": event.latitude,
            "longitude": event.longitude,
            "timestamp": event.timestamp.isoformat(),
            "photo_url": event.photo_url,
            "actor_id": event.actor_id,
            "reference_number": event.reference_number,
            "metadata": meta,
        })
    
    return {
        "lot_id": lot_id,
        "material_category": material.name if material else "Unknown",
        "collector_name": collector.display_name if collector else "Unknown",
        "current_status": lot.status,
        "weight": lot.approximate_weight,
        "events": event_list,
        "verification_url": f"/api/verify/{lot_id}",
    }
