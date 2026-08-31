from typing import Optional

import uuid
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.lot import Lot
from app.models.offer import Offer
from app.models.recycler import Recycler
from app.schemas.offer import OfferCreate


def get_current_user_id(authorization: str = Header(None)) -> Optional[str]:
    if authorization and authorization.startswith("Bearer "):
        return authorization[7:]
    return None


router = APIRouter(prefix="/api/offers", tags=["offers"])


@router.post("/")
def create_offer(
    offer: OfferCreate,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Create an offer from a recycler on a lot."""
    lot = db.query(Lot).filter(Lot.id == offer.lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")

    recycler = db.query(Recycler).filter(Recycler.id == offer.recycler_id).first()
    if not recycler:
        raise HTTPException(status_code=404, detail="Recycler not found")

    valid_until = None
    if offer.valid_until:
        try:
            valid_until = datetime.fromisoformat(offer.valid_until)
        except ValueError:
            valid_until = datetime.utcnow() + timedelta(days=7)
    else:
        valid_until = datetime.utcnow() + timedelta(days=7)

    new_offer = Offer(
        id=str(uuid.uuid4()),
        lot_id=offer.lot_id,
        recycler_id=offer.recycler_id,
        price_per_unit=offer.price_per_unit,
        total_price=offer.total_price,
        status="PENDING",
        valid_until=valid_until,
        notes=offer.notes,
    )
    db.add(new_offer)

    # Update lot status to OFFERED if currently READY_FOR_SALE
    if lot.status == "READY_FOR_SALE":
        lot.status = "OFFERED"
        lot.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(new_offer)

    # Traceability
    if user_id:
        from app.services.traceability import add_event

        add_event(
            db,
            lot.id,
            "OFFER_RECEIVED",
            user_id,
            metadata={"recycler_name": recycler.name, "price": offer.total_price},
        )

    return _offer_to_response(new_offer, db)


@router.get("/")
def list_offers(
    lot_id: Optional[str] = Query(None),
    recycler_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List offers, optionally filtered by lot or recycler."""
    query = db.query(Offer)
    if lot_id:
        query = query.filter(Offer.lot_id == lot_id)
    if recycler_id:
        query = query.filter(Offer.recycler_id == recycler_id)
    offers = query.order_by(Offer.created_at.desc()).all()
    return [_offer_to_response(o, db) for o in offers]


@router.post("/{offer_id}/accept")
def accept_offer(
    offer_id: str,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Collector accepts an offer."""
    offer = db.query(Offer).filter(Offer.id == offer_id).first()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
    if offer.status != "PENDING":
        raise HTTPException(status_code=400, detail=f"Offer is {offer.status}, cannot accept")

    offer.status = "ACCEPTED"
    offer.updated_at = datetime.utcnow()

    # Update lot
    lot = db.query(Lot).filter(Lot.id == offer.lot_id).first()
    if lot:
        lot.status = "ACCEPTED"
        lot.updated_at = datetime.utcnow()

    # Reject other pending offers for same lot
    other_offers = db.query(Offer).filter(
        Offer.lot_id == offer.lot_id,
        Offer.id != offer_id,
        Offer.status == "PENDING",
    ).all()
    for other in other_offers:
        other.status = "REJECTED"
        other.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(offer)

    # Traceability
    if user_id and lot:
        from app.services.traceability import add_event

        add_event(
            db,
            lot.id,
            "OFFER_ACCEPTED",
            user_id,
            metadata={"offer_id": offer_id, "price": offer.total_price},
        )

    return _offer_to_response(offer, db)


@router.post("/{offer_id}/reject")
def reject_offer(offer_id: str, db: Session = Depends(get_db)):
    """Collector rejects an offer."""
    offer = db.query(Offer).filter(Offer.id == offer_id).first()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
    if offer.status != "PENDING":
        raise HTTPException(status_code=400, detail=f"Offer is {offer.status}, cannot reject")

    offer.status = "REJECTED"
    offer.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(offer)

    return _offer_to_response(offer, db)


def _offer_to_response(offer, db):
    recycler = db.query(Recycler).filter(Recycler.id == offer.recycler_id).first()
    return {
        "id": offer.id,
        "lot_id": offer.lot_id,
        "recycler_id": offer.recycler_id,
        "price_per_unit": offer.price_per_unit,
        "total_price": offer.total_price,
        "status": offer.status,
        "valid_until": offer.valid_until.isoformat() if offer.valid_until else None,
        "notes": offer.notes,
        "created_at": offer.created_at.isoformat() if offer.created_at else "",
        "updated_at": offer.updated_at.isoformat() if offer.updated_at else "",
        "recycler_name": recycler.name if recycler else None,
    }
