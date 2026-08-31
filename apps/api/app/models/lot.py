from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship

from app.database import Base


class Lot(Base):
    __tablename__ = "lots"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    collector_id = Column(String, ForeignKey("users.id"), nullable=False)
    material_category_id = Column(String, ForeignKey("material_categories.id"), nullable=False)
    description = Column(String, nullable=True)
    photo_urls = Column(Text, nullable=False, default="[]")  # JSON array stored as text
    approximate_weight = Column(Float, nullable=False)
    condition = Column(String, nullable=False)  # GOOD, FAIR, POOR, MIXED
    source_type = Column(String, nullable=False)  # HOUSEHOLD, COMMERCIAL, INDUSTRIAL, MIXED
    estimated_min_value = Column(Float, nullable=True)
    estimated_max_value = Column(Float, nullable=True)
    estimated_price_per_unit = Column(Float, nullable=True)
    location_lat = Column(Float, nullable=True)
    location_lng = Column(Float, nullable=True)
    location_name = Column(String, nullable=True)
    status = Column(String, nullable=False, default="DRAFT")  # DRAFT, READY_FOR_SALE, OFFERED, ACCEPTED, PICKUP_SCHEDULED, HANDED_OVER, PAYMENT_PENDING, COMPLETED, CANCELLED
    sync_status = Column(String, nullable=False, default="SYNCED")  # LOCAL_ONLY, PENDING_SYNC, SYNCED, SYNC_FAILED
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    collector = relationship("User", backref="lots", foreign_keys=[collector_id])
    material_category = relationship("MaterialCategory", backref="lots", foreign_keys=[material_category_id])
