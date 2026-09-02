from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from .database import Base

class MaterialDataset(Base):
    __tablename__ = "material_dataset"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class PriceDataset(Base):
    __tablename__ = "price_dataset"
    id = Column(Integer, primary_key=True, index=True)
    material_name = Column(String, index=True)
    price_per_kg = Column(Float)
    currency = Column(String, default="INR")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class RecyclerDataset(Base):
    __tablename__ = "recycler_dataset"
    id = Column(Integer, primary_key=True, index=True)
    facility_name = Column(String, index=True)
    registry_number = Column(String, unique=True, index=True)
    address = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class TransactionDataset(Base):
    __tablename__ = "transaction_dataset"
    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float)
    weight = Column(Float)
    material_id = Column(Integer, ForeignKey("material_dataset.id"))
    recycler_id = Column(Integer, ForeignKey("recycler_dataset.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class TraceabilityDataset(Base):
    __tablename__ = "traceability_dataset"
    id = Column(Integer, primary_key=True, index=True)
    transaction_id = Column(Integer, ForeignKey("transaction_dataset.id"))
    location_data = Column(String)
    sha256_hash = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class CollectorDataset(Base):
    __tablename__ = "collector_dataset"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    phone_number = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class AIMLDataset(Base):
    __tablename__ = "ai_ml_dataset"
    id = Column(Integer, primary_key=True, index=True)
    data_type = Column(String)
    data_content = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
