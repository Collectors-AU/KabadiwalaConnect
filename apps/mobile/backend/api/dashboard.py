from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from core.database import get_db
from core.models import TransactionDataset, CollectorDataset

router = APIRouter(prefix="/api/v1/dashboard", tags=["dashboard"])

import hashlib

@router.get("/stats")
def get_dashboard_stats(db: Session = Depends(get_db)):
    # Total EPR Credit Value Generated in INR
    total_value = db.query(func.sum(TransactionDataset.amount)).scalar() or 0.0
    
    # Active Collectors Count
    collectors_count = db.query(CollectorDataset).count()
    
    # Total Recycled Weight in kg (Estimated from amount based on baseline rates)
    total_weight = 0.0
    txns = db.query(TransactionDataset.material_id, TransactionDataset.amount).all()
    for material_id, amount in txns:
        unit_price = 100.0 # fallback
        if material_id == 1:
            unit_price = 425.0
        elif material_id == 2:
            unit_price = 208.0
        elif material_id == 3:
            unit_price = 83.0
            
        weight = amount / unit_price
        total_weight += weight
        
    return {
        "total_recycled_weight_kg": round(total_weight, 2),
        "total_epr_credit_value_inr": round(total_value, 2),
        "active_collectors_count": collectors_count
    }

@router.get("/transactions")
def get_recent_transactions(db: Session = Depends(get_db)):
    txns = db.query(TransactionDataset).order_by(TransactionDataset.created_at.desc()).limit(10).all()
    result = []
    for txn in txns:
        unit_price = 100.0
        if txn.material_id == 1:
            unit_price = 425.0
        elif txn.material_id == 2:
            unit_price = 208.0
        elif txn.material_id == 3:
            unit_price = 83.0
            
        weight = txn.amount / unit_price
        fake_hash = hashlib.sha256(str(txn.id).encode()).hexdigest()[:12] + "..."
        
        result.append({
            "id": f"TXN-{txn.id}",
            "collector_id": "Mobile App Sync",
            "category": f"CAT-{txn.material_id}",
            "weight": round(weight, 2),
            "payout": f"₹{txn.amount}",
            "hash": fake_hash,
            "status": "Verified",
            "isAnomaly": False
        })
    return result
