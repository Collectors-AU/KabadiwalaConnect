from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
import hashlib
from datetime import datetime

from core.database import get_db
from core.models import TransactionDataset, CollectorDataset, AIMLDataset

router = APIRouter(prefix="/api/v1/telephony", tags=["telephony"])

class IVRPayload(BaseModel):
    caller_phone: str
    category_dtmf: int
    weight_dtmf: float

class IVRResponse(BaseModel):
    status: str
    transaction_id: int
    message: str

@router.post("/ivr", response_model=IVRResponse)
def handle_ivr_webhook(payload: IVRPayload, db: Session = Depends(get_db)):
    # Hash caller phone for privacy
    phone_hash = hashlib.sha256(payload.caller_phone.encode()).hexdigest()
    
    # Find or create collector log with the phone hash
    collector = db.query(CollectorDataset).filter(CollectorDataset.phone_number == phone_hash).first()
    if not collector:
        collector = CollectorDataset(
            name="IVR Feature Phone User",
            phone_number=phone_hash
        )
        db.add(collector)
        db.flush()
        
    # Automatically assign a default stock reference image URI to fulfill dataset schemas
    stock_image_uri = "/assets/images/stock_pcb.jpg"
    ai_record = AIMLDataset(
        data_type="stock_image_reference",
        data_content=stock_image_uri
    )
    db.add(ai_record)
    
    # Simple estimate fallback for IVR inputs
    unit_price = 100.0 # baseline fallback
    if payload.category_dtmf == 1:
        unit_price = 425.0
    elif payload.category_dtmf == 2:
        unit_price = 208.0
    elif payload.category_dtmf == 3:
        unit_price = 83.0
        
    estimated_val = payload.weight_dtmf * unit_price
    
    # Log the lot and save to transaction_dataset
    new_txn = TransactionDataset(
        amount=estimated_val,
        material_id=payload.category_dtmf,
        recycler_id=1, # Default mock recycler
        created_at=datetime.utcnow()
    )
    db.add(new_txn)
    
    db.commit()
    
    return IVRResponse(
        status="SUCCESS",
        transaction_id=new_txn.id,
        message=f"Logged {payload.weight_dtmf}kg for category {payload.category_dtmf} using stock image reference."
    )
