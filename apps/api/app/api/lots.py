from typing import Optional

import json
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.lot import Lot
from app.models.material import MaterialCategory
from app.models.user import User
from app.schemas.lot import LotCreate, LotUpdate


def get_current_user_id(authorization: str = Header(None)) -> Optional[str]:
    if authorization and authorization.startswith("Bearer "):
        return authorization[7:]
    return None


router = APIRouter(prefix="/api/lots", tags=["lots"])


@router.post("/")
def create_lot(
    lot_data: LotCreate,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Create a new lot."""
    if not user_id:
        raise HTTPException(status_code=401, detail="Authentication required")

    # Verify material exists
    material = db.query(MaterialCategory).filter(
        MaterialCategory.id == lot_data.material_category_id
    ).first()
    if not material:
        raise HTTPException(status_code=404, detail="Material category not found")

    # Get price estimate
    from app.services.price_engine import estimate

    est = estimate(
        db,
        lot_data.material_category_id,
        lot_data.location_name,
        lot_data.approximate_weight,
        lot_data.condition,
    )

    lot = Lot(
        id=str(uuid.uuid4()),
        collector_id=user_id,
        material_category_id=lot_data.material_category_id,
        description=lot_data.description,
        photo_urls=json.dumps(lot_data.photo_urls),
        approximate_weight=lot_data.approximate_weight,
        condition=lot_data.condition,
        source_type=lot_data.source_type,
        estimated_min_value=est.min_price,
        estimated_max_value=est.max_price,
        estimated_price_per_unit=est.price_per_unit,
        location_lat=lot_data.location_lat,
        location_lng=lot_data.location_lng,
        location_name=lot_data.location_name,
        status="DRAFT",
        sync_status="SYNCED",
    )
    db.add(lot)
    db.commit()
    db.refresh(lot)

    # Add traceability event
    from app.services.traceability import add_event

    add_event(
        db,
        lot.id,
        "COLLECTED",
        user_id,
        location=lot_data.location_name,
        latitude=lot_data.location_lat,
        longitude=lot_data.location_lng,
    )

    return _lot_to_response(lot, db)


@router.get("/")
def list_lots(
    collector_id: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    """List lots with optional filters."""
    query = db.query(Lot)
    if collector_id:
        query = query.filter(Lot.collector_id == collector_id)
    if status:
        query = query.filter(Lot.status == status)
    lots = query.order_by(Lot.created_at.desc()).offset(skip).limit(limit).all()
    return [_lot_to_response(lot, db) for lot in lots]


@router.get("/{lot_id}")
def get_lot(lot_id: str, db: Session = Depends(get_db)):
    """Get lot details."""
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")
    return _lot_to_response(lot, db)


@router.put("/{lot_id}")
def update_lot(
    lot_id: str,
    lot_data: LotUpdate,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Update a lot."""
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")

    update_fields = lot_data.model_dump(exclude_unset=True)
    if "photo_urls" in update_fields and update_fields["photo_urls"] is not None:
        update_fields["photo_urls"] = json.dumps(update_fields["photo_urls"])

    for field, value in update_fields.items():
        if value is not None:
            setattr(lot, field, value)

    # If status changed to READY_FOR_SALE, add traceability event
    if "status" in update_fields and update_fields["status"] == "READY_FOR_SALE" and user_id:
        from app.services.traceability import add_event

        add_event(db, lot.id, "LISTED", user_id, location=lot.location_name)

    lot.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(lot)
    return _lot_to_response(lot, db)


@router.post("/{lot_id}/classify")
def classify_lot(lot_id: str, db: Session = Depends(get_db)):
    """Classify material from lot photos (demo classifier)."""
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")

    from app.services.classifier import classify

    result = classify(image_data=lot.description, filename=lot_id)
    return result


@router.get("/{lot_id}/estimate")
def get_lot_estimate(lot_id: str, db: Session = Depends(get_db)):
    """Get price estimate for a lot."""
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")

    from app.services.price_engine import estimate

    est = estimate(
        db, lot.material_category_id, lot.location_name, lot.approximate_weight, lot.condition
    )

    return {
        "min_price": est.min_price,
        "max_price": est.max_price,
        "reference_price": est.reference_price,
        "confidence": est.confidence,
        "data_points_used": est.data_points_used,
        "trend": est.trend,
        "price_per_unit": est.price_per_unit,
        "total_estimated_value": est.total_estimated_value,
    }


def _lot_to_response(lot: Lot, db: Session) -> dict:
    """Convert a Lot model to response dict with extra fields."""
    material = db.query(MaterialCategory).filter(
        MaterialCategory.id == lot.material_category_id
    ).first()
    collector = db.query(User).filter(User.id == lot.collector_id).first()

    photo_urls = []
    try:
        photo_urls = json.loads(lot.photo_urls) if lot.photo_urls else []
    except (json.JSONDecodeError, TypeError):
        pass

    return {
        "id": lot.id,
        "collector_id": lot.collector_id,
        "material_category_id": lot.material_category_id,
        "description": lot.description,
        "photo_urls": photo_urls,
        "approximate_weight": lot.approximate_weight,
        "condition": lot.condition,
        "source_type": lot.source_type,
        "estimated_min_value": lot.estimated_min_value,
        "estimated_max_value": lot.estimated_max_value,
        "estimated_price_per_unit": lot.estimated_price_per_unit,
        "location_lat": lot.location_lat,
        "location_lng": lot.location_lng,
        "location_name": lot.location_name,
        "status": lot.status,
        "sync_status": lot.sync_status,
        "created_at": lot.created_at.isoformat() if lot.created_at else "",
        "updated_at": lot.updated_at.isoformat() if lot.updated_at else "",
        "material_name": material.name if material else None,
        "collector_name": collector.display_name if collector else None,
    }
