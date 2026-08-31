from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.lot import Lot
from app.models.transaction import Transaction
from app.models.recycler import Recycler
from sqlalchemy import func

router = APIRouter()

@router.get("/metrics")
def get_metrics(db: Session = Depends(get_db)):
    total_lots = db.query(Lot).count()
    total_weight = db.query(func.sum(Lot.approximate_weight)).scalar() or 0
    completed_tx = db.query(Transaction).filter(Transaction.transaction_status == "COMPLETED").count()
    verified_recyclers = db.query(Recycler).filter(Recycler.authorization_status == "VERIFIED").count()
    
    return {
        "total_lots": total_lots,
        "total_weight_kg": float(total_weight),
        "completed_transactions": completed_tx,
        "verified_recyclers": verified_recyclers
    }
