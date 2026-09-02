
import os
import sys
import pandas as pd
from sqlalchemy.orm import Session

# Add backend directory to sys.path to allow importing core
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.database import engine, SessionLocal, Base
from core.models import PriceDataset, RecyclerDataset

def seed_data():
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # Seed Price Dataset
        price_data = [
            {"material_name": "Copper Cable", "price_per_kg": 425.0, "currency": "INR"},
            {"material_name": "High-grade PCB", "price_per_kg": 208.0, "currency": "INR"},
            {"material_name": "Li-ion Battery", "price_per_kg": 83.0, "currency": "INR"}
        ]
        
        if db.query(PriceDataset).count() == 0:
            for item in price_data:
                db_item = PriceDataset(**item)
                db.add(db_item)
            print("Seeded PriceDataset")
        
        # Seed Recycler Dataset
        recycler_data = [
            {"facility_name": "CPCB Authorized Facility 1", "registry_number": "CPCB-AUTH-001", "address": "Delhi"},
            {"facility_name": "CPCB Authorized Facility 2", "registry_number": "CPCB-AUTH-002", "address": "Mumbai"}
        ]
        
        if db.query(RecyclerDataset).count() == 0:
            # Using pandas as requested
            df = pd.DataFrame(recycler_data)
            for _, row in df.iterrows():
                db_item = RecyclerDataset(
                    facility_name=row['facility_name'],
                    registry_number=row['registry_number'],
                    address=row['address']
                )
                db.add(db_item)
            print("Seeded RecyclerDataset")
            
        db.commit()
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
