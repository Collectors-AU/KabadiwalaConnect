from typing import Optional

from typing import List, Optional

from pydantic import BaseModel


class HandoverRequest(BaseModel):
    lot_id: str
    recycler_id: str
    offer_id: Optional[str] = None
    quoted_price: float
    quoted_weight: float
    collection_location: Optional[str] = None
    handover_location: Optional[str] = None


class HandoverConfirmRequest(BaseModel):
    final_weight: float
    final_price: Optional[float] = None
    handover_photo_url: Optional[str] = None


class PaymentRequest(BaseModel):
    transaction_id: str
    payment_method: str  # CASH, UPI, BANK_TRANSFER
    payment_reference: Optional[str] = None
    amount: Optional[float] = None


class TransactionResponse(BaseModel):
    id: str
    lot_id: str
    collector_id: str
    recycler_id: str
    offer_id: Optional[str] = None
    quoted_price: float
    final_price: Optional[float] = None
    quoted_weight: float
    final_weight: Optional[float] = None
    collection_location: Optional[str] = None
    handover_location: Optional[str] = None
    handover_photo_url: Optional[str] = None
    handover_reference: str
    payment_method: Optional[str] = None
    payment_status: str
    payment_reference: Optional[str] = None
    transaction_status: str
    created_at: str
    completed_at: Optional[str] = None
    collector_name: Optional[str] = None
    recycler_name: Optional[str] = None
    material_name: Optional[str] = None

    class Config:
        from_attributes = True


class EarningsSummary(BaseModel):
    collector_id: str
    total_earnings: float
    total_transactions: int
    total_weight_kg: float
    earnings_by_material: List[dict] = []
    recent_transactions: List[dict] = []


class PaymentResponse(BaseModel):
    transaction_id: str
    payment_status: str
    payment_method: Optional[str] = None
    payment_reference: Optional[str] = None
    amount: float
