from typing import Optional


from pydantic import BaseModel


class OfferCreate(BaseModel):
    lot_id: str
    recycler_id: str
    price_per_unit: float
    total_price: float
    valid_until: Optional[str] = None
    notes: Optional[str] = None


class OfferResponse(BaseModel):
    id: str
    lot_id: str
    recycler_id: str
    price_per_unit: float
    total_price: float
    status: str
    valid_until: Optional[str] = None
    notes: Optional[str] = None
    created_at: str
    updated_at: str
    recycler_name: Optional[str] = None

    class Config:
        from_attributes = True
