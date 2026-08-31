from typing import Optional

"""Aggregation service: find opportunities for collectors to group lots together for better pricing."""
import json
from datetime import datetime
from sqlalchemy.orm import Session
from app.models.lot import Lot
from app.models.aggregation import AggregationGroup, AggregationMember
from app.models.material import MaterialCategory
from app.services.price_engine import estimate

def find_opportunities(db: Session, collector_id: str, material_category_id: Optional[str] = None) -> list:
    """
    Find aggregation opportunities for a collector.
    
    Looks for:
    1. Existing forming groups the collector can join
    2. Other collectors' lots with the same material nearby that could form a new group
    
    Returns opportunities with individual vs group pricing comparison.
    """
    # Get collector's lots that are READY_FOR_SALE
    collector_lots = db.query(Lot).filter(
        Lot.collector_id == collector_id,
        Lot.status.in_(["READY_FOR_SALE", "DRAFT"])
    )
    if material_category_id:
        collector_lots = collector_lots.filter(Lot.material_category_id == material_category_id)
    collector_lots = collector_lots.all()
    
    if not collector_lots:
        return []
    
    opportunities = []
    
    # Find existing groups
    groups_query = db.query(AggregationGroup).filter(AggregationGroup.status == "FORMING")
    if material_category_id:
        groups_query = groups_query.filter(AggregationGroup.material_category_id == material_category_id)
    forming_groups = groups_query.all()
    
    for group in forming_groups:
        material = db.query(MaterialCategory).filter(MaterialCategory.id == group.material_category_id).first()
        members = db.query(AggregationMember).filter(AggregationMember.group_id == group.id).all()
        
        # Check if collector already joined
        already_joined = any(m.collector_id == collector_id for m in members)
        if already_joined:
            continue
        
        # Find matching lots from this collector
        matching_lots = [l for l in collector_lots if l.material_category_id == group.material_category_id]
        if not matching_lots:
            continue
        
        potential_weight = group.total_weight + sum(l.approximate_weight for l in matching_lots)
        
        # Weight bonus for group
        individual_bonus = 1.0
        group_bonus = 1.0
        if potential_weight > 100:
            group_bonus = 1.10
        elif potential_weight > 50:
            group_bonus = 1.05
        
        for lot in matching_lots:
            if lot.approximate_weight > 100:
                individual_bonus = 1.10
            elif lot.approximate_weight > 50:
                individual_bonus = 1.05
        
        bonus_percent = ((group_bonus - individual_bonus) / individual_bonus) * 100 if individual_bonus > 0 else 0
        
        opportunities.append({
            "id": group.id,
            "material_category_id": group.material_category_id,
            "status": group.status,
            "total_weight": group.total_weight,
            "individual_price_estimate": group.individual_price_estimate,
            "group_price_estimate": group.group_price_estimate,
            "location_lat": group.location_lat,
            "location_lng": group.location_lng,
            "created_at": group.created_at.isoformat(),
            "material_name": material.name if material else "Unknown",
            "member_count": len(members),
            "potential_bonus_percent": round(bonus_percent, 1),
        })
    
    return opportunities
