from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from core.database import get_db
from core.models import TransactionDataset, CollectorDataset, TraceabilityDataset

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
    records = db.query(
        TransactionDataset, TraceabilityDataset
    ).outerjoin(
        TraceabilityDataset, TransactionDataset.id == TraceabilityDataset.transaction_id
    ).order_by(TransactionDataset.created_at.desc()).limit(10).all()
    
    result = []
    for txn, trace in records:
        real_hash = trace.sha256_hash if trace else "N/A"
        is_anomaly = (txn.status == "ANOMALOUS_FLAGGED")
        
        result.append({
            "id": f"TXN-{txn.id}",
            "collector_id": "Mobile App Sync",
            "category": f"CAT-{txn.material_id}",
            "weight": round(txn.weight, 2) if txn.weight else 0.0,
            "payout": f"₹{txn.amount}",
            "hash": real_hash[:12] + "..." if real_hash != "N/A" else "N/A",
            "status": txn.status if txn.status else "Verified",
            "isAnomaly": is_anomaly
        })
    return result
