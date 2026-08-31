from typing import Optional

"""Match recyclers to lots based on multiple criteria."""
import json
import math
from sqlalchemy.orm import Session
from app.models.recycler import Recycler
from app.models.lot import Lot
from app.models.material import MaterialCategory

def haversine_km(lat1, lon1, lat2, lon2):
    """Calculate distance between two points in km."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c

def match(db: Session, lot_id: str) -> list:
    """
    Find and rank recyclers for a given lot.
    
    Scoring criteria:
    - Material compatibility (must accept the material): required
    - Authorization status: VERIFIED=+30, PENDING=+15, UNKNOWN=+0
    - Price offered vs market: higher = better, up to +25 points
    - Distance: closer = better, up to +20 points
    - Pickup available: +10 points
    - Within service radius: +15 points (0 if outside radius)
    """
    lot = db.query(Lot).filter(Lot.id == lot_id).first()
    if not lot:
        return []
    
    material = db.query(MaterialCategory).filter(MaterialCategory.id == lot.material_category_id).first()
    if not material:
        return []
    
    recyclers = db.query(Recycler).all()
    matches = []
    
    for recycler in recyclers:
        materials_accepted = json.loads(recycler.materials_accepted) if recycler.materials_accepted else []
        offered_rates = json.loads(recycler.offered_rates) if recycler.offered_rates else {}
        
        # Must accept the material
        if material.name not in materials_accepted:
            continue
        
        score = 0.0
        reasons = []
        
        # Authorization score
        if recycler.authorization_status == "VERIFIED":
            score += 30
            reasons.append("Verified authorization")
        elif recycler.authorization_status == "PENDING_VERIFICATION":
            score += 15
            reasons.append("Pending verification")
        
        # Price score
        rate = offered_rates.get(material.name, 0)
        if rate > 0:
            # Score based on rate relative to average
            all_rates = [float(r) for r in offered_rates.values() if r]
            if all_rates:
                price_score = min(25, (rate / max(all_rates)) * 25)
                score += price_score
                reasons.append(f"Offers Rs.{rate}/kg for {material.name}")
        
        # Distance score
        if lot.location_lat and lot.location_lng:
            distance = haversine_km(lot.location_lat, lot.location_lng, recycler.latitude, recycler.longitude)
            if distance <= recycler.service_radius_km:
                score += 15
                reasons.append(f"Within service radius ({distance:.1f}km)")
            
            # Distance score: 20 points for 0km, 0 points for 50km+
            dist_score = max(0, 20 * (1 - distance / 50))
            score += dist_score
            reasons.append(f"Distance: {distance:.1f}km")
        else:
            # Default moderate distance if no location
            score += 10
            reasons.append("Location not specified for lot")
        
        # Pickup bonus
        if recycler.pickup_available:
            score += 10
            reasons.append("Pickup available")
        
        matches.append({
            "recycler": {
                "id": recycler.id,
                "user_id": recycler.user_id,
                "name": recycler.name,
                "facility_location": recycler.facility_location,
                "latitude": recycler.latitude,
                "longitude": recycler.longitude,
                "materials_accepted": materials_accepted,
                "authorization_status": recycler.authorization_status,
                "authorization_reference": recycler.authorization_reference,
                "contact": recycler.contact,
                "offered_rates": offered_rates,
                "pickup_available": recycler.pickup_available,
                "service_radius_km": recycler.service_radius_km,
            },
            "match_score": round(score, 1),
            "reasons": reasons,
        })
    
    matches.sort(key=lambda m: m["match_score"], reverse=True)
    return matches
