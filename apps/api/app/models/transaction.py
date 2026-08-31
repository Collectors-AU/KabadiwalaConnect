from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    lot_id = Column(String, ForeignKey("lots.id"), nullable=False)
    collector_id = Column(String, ForeignKey("users.id"), nullable=False)
    recycler_id = Column(String, ForeignKey("recyclers.id"), nullable=False)
    offer_id = Column(String, ForeignKey("offers.id"), nullable=True)
    quoted_price = Column(Float, nullable=False)
    final_price = Column(Float, nullable=True)
    quoted_weight = Column(Float, nullable=False)
    final_weight = Column(Float, nullable=True)
    collection_location = Column(String, nullable=True)
    handover_location = Column(String, nullable=True)
    handover_photo_url = Column(String, nullable=True)
    handover_reference = Column(String, unique=True, nullable=False)  # "KAB-TXN-XXXXX"
    payment_method = Column(String, nullable=True)  # CASH, UPI, BANK_TRANSFER
    payment_status = Column(String, nullable=False, default="PENDING")  # PENDING, PAID, FAILED, REFUNDED
    payment_reference = Column(String, nullable=True)
    transaction_status = Column(String, nullable=False, default="INITIATED")  # INITIATED, PICKUP_SCHEDULED, IN_TRANSIT, HANDED_OVER, PAYMENT_PENDING, COMPLETED, CANCELLED, DISPUTED
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)

    lot = relationship("Lot", backref="transactions", foreign_keys=[lot_id])
    collector = relationship("User", backref="transactions", foreign_keys=[collector_id])
    recycler = relationship("Recycler", backref="transactions", foreign_keys=[recycler_id])
    offer = relationship("Offer", backref="transaction", foreign_keys=[offer_id])
