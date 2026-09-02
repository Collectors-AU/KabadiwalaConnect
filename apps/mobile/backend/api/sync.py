from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy.orm import Session
from datetime import datetime

from core.database import get_db
from core.models import TransactionDataset, TraceabilityDataset
from core.anomaly import detector

router = APIRouter(prefix="/api/v1", tags=["sync"])

# Pydantic models for request validation
class TransactionItem(BaseModel):
    txn_id: str
    lot_id: str
    collector_id: int
    category_code: int
    approx_weight_kg: float
    estimated_val_inr: float
    sha256_hash: str
    handover_gps: str
    timestamp_utc: str
    status: str

class SyncPayload(BaseModel):
    device_id: str
    synced_at: str
    pending_transactions: List[TransactionItem]
    
class SyncResponse(BaseModel):
    status: str
    processed_count: int
    anomalies_flagged: int
    synced_txn_ids: List[str]

@router.post("/sync", response_model=SyncResponse)
def sync_transactions(payload: SyncPayload, db: Session = Depends(get_db)):
    processed_count = 0
    anomalies_flagged = 0
    synced_txn_ids = []
    
    for item in payload.pending_transactions:
        # 1. Check for anomaly
        is_anomalous = detector.is_transaction_anomalous(
            weight=item.approx_weight_kg,
            value=item.estimated_val_inr,
            cat_id=item.category_code
        )
        
        if is_anomalous:
            anomalies_flagged += 1
            # Skip invalid/anomalous records
            continue
            
        # 2. Insert valid record into transaction_dataset
        try:
            created_time = datetime.fromisoformat(item.timestamp_utc.replace('Z', '+00:00'))
        except ValueError:
            created_time = datetime.utcnow()
            
        new_txn = TransactionDataset(
            amount=item.estimated_val_inr,
            material_id=item.category_code,
            recycler_id=1, # Defaulting to first recycler for now
            created_at=created_time
        )
        db.add(new_txn)
        db.flush() # To get the transaction ID
        
        # 3. Insert into traceability_dataset
        new_trace = TraceabilityDataset(
            transaction_id=new_txn.id,
            location_data=item.handover_gps,
            created_at=created_time
        )
        db.add(new_trace)
        
        processed_count += 1
        synced_txn_ids.append(item.txn_id)
        
    db.commit()
    
    return SyncResponse(
        status="SUCCESS",
        processed_count=processed_count,
        anomalies_flagged=anomalies_flagged,
        synced_txn_ids=synced_txn_ids
    )
