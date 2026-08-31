from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class AggregationGroup(Base):
    __tablename__ = "aggregation_groups"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    material_category_id = Column(String, ForeignKey("material_categories.id"), nullable=False)
    status = Column(String, nullable=False, default="FORMING")  # FORMING, READY, MATCHED, COMPLETED, CANCELLED
    total_weight = Column(Float, nullable=False, default=0.0)
    individual_price_estimate = Column(Float, nullable=False, default=0.0)
    group_price_estimate = Column(Float, nullable=False, default=0.0)
    location_lat = Column(Float, nullable=False, default=0.0)
    location_lng = Column(Float, nullable=False, default=0.0)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    members = relationship("AggregationMember", backref="group", foreign_keys="AggregationMember.group_id")


class AggregationMember(Base):
    __tablename__ = "aggregation_members"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    group_id = Column(String, ForeignKey("aggregation_groups.id"), nullable=False)
    lot_id = Column(String, ForeignKey("lots.id"), nullable=False)
    collector_id = Column(String, ForeignKey("users.id"), nullable=False)
    joined_at = Column(DateTime, nullable=False, default=datetime.utcnow)
