from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class Offer(Base):
    __tablename__ = "offers"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    lot_id = Column(String, ForeignKey("lots.id"), nullable=False)
    recycler_id = Column(String, ForeignKey("recyclers.id"), nullable=False)
    price_per_unit = Column(Float, nullable=False)
    total_price = Column(Float, nullable=False)
    status = Column(String, nullable=False, default="PENDING")  # PENDING, ACCEPTED, REJECTED, EXPIRED, WITHDRAWN
    valid_until = Column(DateTime, nullable=True)
    notes = Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    lot = relationship("Lot", backref="offers", foreign_keys=[lot_id])
    recycler = relationship("Recycler", backref="offers", foreign_keys=[recycler_id])
