from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, DateTime

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    role = Column(String, nullable=False)  # COLLECTOR, RECYCLER, ADMIN
    display_name = Column(String, nullable=False)
    preferred_language = Column(String, nullable=False, default="en")  # en, hi, mr
    operating_area = Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
