import uuid
from datetime import datetime, timedelta
from app.models.user import User
from app.models.material import MaterialCategory
from app.models.recycler import Recycler
from app.models.price import PriceObservation
from typing import Optional

def seed_all(db):
    if db.query(MaterialCategory).first():
        return # Already seeded

    # Materials
    materials = [
        {"name": "PCB", "display_name_en": "PCB", "display_name_hi": "पीसीबी", "display_name_mr": "पीसीबी", "hazard_level": "MEDIUM", "description": "Printed Circuit Boards", "icon": "wrench"},
        {"name": "CABLE", "display_name_en": "Cable", "display_name_hi": "केबल/तार", "display_name_mr": "केबल/तार", "hazard_level": "LOW", "description": "Cables and wires", "icon": "cable"}
    ]
    mat_ids = {}
    for m in materials:
        m_obj = MaterialCategory(id=str(uuid.uuid4()), created_at=datetime.utcnow(), **m)
        db.add(m_obj)
        mat_ids[m['name']] = m_obj.id
    
    # Commit first pass
    db.commit()

    # Create dummy user
    u = User(id=str(uuid.uuid4()), role="COLLECTOR", display_name="Ramesh Kumar", preferred_language="hi", created_at=datetime.utcnow(), updated_at=datetime.utcnow())
    db.add(u)
    
    # Recycler
    r_user = User(id=str(uuid.uuid4()), role="RECYCLER", display_name="GreenTech", preferred_language="en", created_at=datetime.utcnow(), updated_at=datetime.utcnow())
    db.add(r_user)
    
    r = Recycler(id=str(uuid.uuid4()), user_id=r_user.id, name="GreenTech E-Waste", facility_location="Mumbai", latitude=19.0, longitude=73.0, materials_accepted='["PCB"]', authorization_status="VERIFIED", pickup_available=True, service_radius_km=30, offered_rates='{"PCB": 168}', created_at=datetime.utcnow(), updated_at=datetime.utcnow())
    db.add(r)
    db.commit()
    
    # Add dummy price
    po = PriceObservation(
        id=str(uuid.uuid4()),
        material_category_id=mat_ids["PCB"],
        location="Mumbai",
        observed_at=datetime.utcnow(),
        buying_price=162.0,
        unit="KG",
        source="SEEDED_DEMO_DATA",
        quality="GOOD"
    )
    db.add(po)
    db.commit()

