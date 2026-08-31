from typing import Optional

"""Price estimation engine for e-waste materials."""
import json
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.price import PriceObservation
from app.models.material import MaterialCategory

class PriceEstimate:
    def __init__(self, min_price, max_price, reference_price, confidence, data_points_used, trend, price_per_unit, total_estimated_value):
        self.min_price = min_price
        self.max_price = max_price
        self.reference_price = reference_price
        self.confidence = confidence
        self.data_points_used = data_points_used
        self.trend = trend
        self.price_per_unit = price_per_unit
        self.total_estimated_value = total_estimated_value

def estimate(db: Session, material_category_id: str, location: Optional[str], weight: float, condition: str) -> PriceEstimate:
    """
    Estimate price for a lot based on recent price observations.
    
    1. Query PriceObservation for last 90 days for this material
    2. Calculate median, min, max from observations
    3. Apply condition adjustment: GOOD=1.0, FAIR=0.85, POOR=0.7, MIXED=0.8
    4. Apply weight bonus: >50kg=+5%, >100kg=+10%
    5. Calculate trend by comparing recent 30d avg vs prior 30d avg
    """
    # Get observations from last 90 days
    cutoff = datetime.utcnow() - timedelta(days=90)
    observations = db.query(PriceObservation).filter(
        PriceObservation.material_category_id == material_category_id,
        PriceObservation.observed_at >= cutoff
    ).order_by(PriceObservation.observed_at.desc()).all()
    
    if not observations:
        # Return fallback estimate
        return PriceEstimate(
            min_price=0, max_price=0, reference_price=0,
            confidence=0, data_points_used=0, trend="STABLE",
            price_per_unit=0, total_estimated_value=0
        )
    
    prices = [obs.buying_price for obs in observations]
    prices.sort()
    
    n = len(prices)
    median_price = prices[n // 2] if n % 2 == 1 else (prices[n // 2 - 1] + prices[n // 2]) / 2
    min_observed = prices[0]
    max_observed = prices[-1]
    
    # Condition adjustment
    condition_factors = {"GOOD": 1.0, "FAIR": 0.85, "POOR": 0.7, "MIXED": 0.8}
    condition_factor = condition_factors.get(condition, 0.85)
    
    # Weight bonus
    weight_bonus = 1.0
    if weight > 100:
        weight_bonus = 1.10
    elif weight > 50:
        weight_bonus = 1.05
    
    adjusted_price = median_price * condition_factor * weight_bonus
    adjusted_min = min_observed * condition_factor * weight_bonus
    adjusted_max = max_observed * condition_factor * weight_bonus
    
    # Trend: compare recent 30d vs prior 30-60d
    recent_cutoff = datetime.utcnow() - timedelta(days=30)
    prior_cutoff = datetime.utcnow() - timedelta(days=60)
    
    recent_prices = [o.buying_price for o in observations if o.observed_at >= recent_cutoff]
    prior_prices = [o.buying_price for o in observations if prior_cutoff <= o.observed_at < recent_cutoff]
    
    trend = "STABLE"
    if recent_prices and prior_prices:
        recent_avg = sum(recent_prices) / len(recent_prices)
        prior_avg = sum(prior_prices) / len(prior_prices)
        change = (recent_avg - prior_avg) / prior_avg
        if change > 0.05:
            trend = "UP"
        elif change < -0.05:
            trend = "DOWN"
    
    # Confidence based on data points
    confidence = min(1.0, n / 30)  # Full confidence at 30+ points
    
    return PriceEstimate(
        min_price=round(adjusted_min * weight, 2),
        max_price=round(adjusted_max * weight, 2),
        reference_price=round(adjusted_price * weight, 2),
        confidence=round(confidence, 2),
        data_points_used=n,
        trend=trend,
        price_per_unit=round(adjusted_price, 2),
        total_estimated_value=round(adjusted_price * weight, 2)
    )

def get_current_prices(db: Session, material_category_id: Optional[str] = None) -> list:
    """Get current price summary for each material category."""
    cutoff = datetime.utcnow() - timedelta(days=30)
    
    query = db.query(MaterialCategory)
    if material_category_id:
        query = query.filter(MaterialCategory.id == material_category_id)
    materials = query.all()
    
    results = []
    for mat in materials:
        observations = db.query(PriceObservation).filter(
            PriceObservation.material_category_id == mat.id,
            PriceObservation.observed_at >= cutoff
        ).all()
        
        if not observations:
            continue
        
        prices = [o.buying_price for o in observations]
        avg_price = sum(prices) / len(prices)
        
        # Trend calculation
        recent = datetime.utcnow() - timedelta(days=7)
        recent_prices = [o.buying_price for o in observations if o.observed_at >= recent]
        older_prices = [o.buying_price for o in observations if o.observed_at < recent]
        
        trend = "STABLE"
        if recent_prices and older_prices:
            r_avg = sum(recent_prices) / len(recent_prices)
            o_avg = sum(older_prices) / len(older_prices)
            change = (r_avg - o_avg) / o_avg
            if change > 0.03:
                trend = "UP"
            elif change < -0.03:
                trend = "DOWN"
        
        last_obs = max(observations, key=lambda o: o.observed_at)
        
        results.append({
            "material_category_id": mat.id,
            "material_name": mat.name,
            "current_price": round(avg_price, 2),
            "min_price": round(min(prices), 2),
            "max_price": round(max(prices), 2),
            "unit": "KG",
            "trend": trend,
            "last_updated": last_obs.observed_at.isoformat()
        })
    
    return results

def get_price_trends(db: Session, material_category_id: str, period: str = "30d") -> dict:
    """Get price trend data points for a material over a period."""
    days_map = {"7d": 7, "30d": 30, "90d": 90}
    days = days_map.get(period, 30)
    cutoff = datetime.utcnow() - timedelta(days=days)
    
    material = db.query(MaterialCategory).filter(MaterialCategory.id == material_category_id).first()
    material_name = material.name if material else "Unknown"
    
    observations = db.query(PriceObservation).filter(
        PriceObservation.material_category_id == material_category_id,
        PriceObservation.observed_at >= cutoff
    ).order_by(PriceObservation.observed_at.asc()).all()
    
    # Group by date and average
    date_prices = {}
    for obs in observations:
        date_key = obs.observed_at.strftime("%Y-%m-%d")
        if date_key not in date_prices:
            date_prices[date_key] = []
        date_prices[date_key].append(obs.buying_price)
    
    data_points = []
    for date_str, prices in sorted(date_prices.items()):
        data_points.append({
            "date": date_str,
            "price": round(sum(prices) / len(prices), 2)
        })
    
    # Calculate trend
    trend_direction = "STABLE"
    change_percent = 0.0
    if len(data_points) >= 2:
        first_price = data_points[0]["price"]
        last_price = data_points[-1]["price"]
        if first_price > 0:
            change_percent = round(((last_price - first_price) / first_price) * 100, 2)
            if change_percent > 3:
                trend_direction = "UP"
            elif change_percent < -3:
                trend_direction = "DOWN"
    
    return {
        "material_category_id": material_category_id,
        "material_name": material_name,
        "period": period,
        "data_points": data_points,
        "trend_direction": trend_direction,
        "change_percent": change_percent
    }
