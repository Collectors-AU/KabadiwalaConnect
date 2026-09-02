from fastapi import APIRouter, Depends, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session
from datetime import datetime, timezone
import hashlib

from core.database import get_db
from core.models import TransactionDataset, TraceabilityDataset, CollectorDataset

router = APIRouter(prefix="/api/v1/telephony", tags=["telephony"])

CATEGORY_MAP = {
    '1': {'code': 'CABLE', 'name': 'Insulated Copper Wire', 'rate': 425.0, 'img': '/static/assets/stock_cable.jpg', 'code_eee': 'CEEW4'},
    '2': {'code': 'PCB_HIGH', 'name': 'High-Grade Boards', 'rate': 208.0, 'img': '/static/assets/stock_pcb.jpg', 'code_eee': 'ITEW2'},
    '3': {'code': 'BATTERY', 'name': 'Lithium Battery Cells', 'rate': 83.0, 'img': '/static/assets/stock_battery.jpg', 'code_eee': 'BWM-LI'},
}

class IVRResponse(BaseModel):
    status: str
    payout: float
    transaction_id: int

@router.post("/ivr", response_model=IVRResponse)
def handle_ivr_webhook(From: str = Form(...), Digits: str = Form(...), db: Session = Depends(get_db)) -> IVRResponse:
    # Parse digits: {category_digit}*{weight_kg}
    parts = Digits.split('*')
    category_digit = parts[0]
    weight_kg = float(parts[1]) if len(parts) > 1 else 0.0

    category_info = CATEGORY_MAP.get(category_digit)
    if not category_info:
        # Fallback to category 1
        category_info = CATEGORY_MAP['1']

    total_payout = category_info['rate'] * weight_kg
    timestamp_utc = datetime.now(timezone.utc)
    
    # Hash caller phone for privacy
    phone_hash = hashlib.sha256(From.encode()).hexdigest()
    
    # Generate SHA-256 tamper digest for transaction
    raw_signature = f"{From}|{timestamp_utc.isoformat()}|0.0,0.0|{weight_kg:.2f}|{category_info['code']}"
    sha256_digest = hashlib.sha256(raw_signature.encode()).hexdigest()

    # Find or create collector
    collector = db.query(CollectorDataset).filter(CollectorDataset.phone_number == phone_hash).first()
    if not collector:
        collector = CollectorDataset(
            name="IVR Caller",
            phone_number=phone_hash
        )
        db.add(collector)
        db.flush()

    # Insert into transaction dataset
    new_txn = TransactionDataset(
        amount=total_payout,
        weight=weight_kg,
        status='LOCAL_PENDING',
        reference_image_uri=category_info['img'],
        material_id=int(category_digit),
        recycler_id=1,  # Default Recycler
        created_at=timestamp_utc.replace(tzinfo=None)
    )
    db.add(new_txn)
    db.flush()

    # Insert into traceability dataset
    new_trace = TraceabilityDataset(
        transaction_id=new_txn.id,
        location_data="0.0,0.0",
        sha256_hash=sha256_digest,
        created_at=timestamp_utc.replace(tzinfo=None)
    )
    db.add(new_trace)
    
    db.commit()

    return IVRResponse(
        status="SUCCESS",
        payout=total_payout,
        transaction_id=new_txn.id
    )
