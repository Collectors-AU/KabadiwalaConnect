from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, Boolean, DateTime, ForeignKey

from app.database import Base


class RecyclerDemand(Base):
    __tablename__ = "recycler_demands"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    recycler_id = Column(String, ForeignKey("recyclers.id"), nullable=False)
    material_category_id = Column(String, ForeignKey("material_categories.id"), nullable=False)
    required_weight = Column(Float, nullable=False)
    offered_price = Column(Float, nullable=False)
    pickup_available = Column(Boolean, nullable=False, default=False)
    service_radius_km = Column(Float, nullable=False, default=10.0)
    valid_until = Column(DateTime, nullable=False)
    status = Column(String, nullable=False, default="ACTIVE")  # ACTIVE, FULFILLED, EXPIRED, CANCELLED
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
