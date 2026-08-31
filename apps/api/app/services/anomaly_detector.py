from typing import Optional

"""Detect anomalies in transactions: price outliers, weight discrepancies, unusual patterns."""
from sqlalchemy.orm import Session
from app.models.transaction import Transaction
from app.models.price import PriceObservation
from app.models.lot import Lot
from datetime import datetime, timedelta

class Anomaly:
    def __init__(self, severity: str, reason: str, expected_range: str, actual_value: str):
        self.severity = severity  # LOW, MEDIUM, HIGH
        self.reason = reason
        self.expected_range = expected_range
        self.actual_value = actual_value
    
    def to_dict(self):
        return {
            "severity": self.severity,
            "reason": self.reason,
            "expected_range": self.expected_range,
            "actual_value": self.actual_value,
        }

def check_transaction(db: Session, transaction: Transaction) -> list:
    """
    Check a transaction for anomalies.
    
    Checks:
    1. Price below 70% of recent average for that material
    2. Weight discrepancy > 20% between quoted and final
    3. Transaction completed unusually fast (< 10 minutes)
    4. Price above 130% of recent average
    """
    anomalies = []
    
    lot = db.query(Lot).filter(Lot.id == transaction.lot_id).first()
    if not lot:
        return anomalies
    
    # Get recent price observations
    cutoff = datetime.utcnow() - timedelta(days=30)
    observations = db.query(PriceObservation).filter(
        PriceObservation.material_category_id == lot.material_category_id,
        PriceObservation.observed_at >= cutoff
    ).all()
    
    if observations:
        avg_price = sum(o.buying_price for o in observations) / len(observations)
        
        # Check quoted price vs average
        price_per_kg = transaction.quoted_price / transaction.quoted_weight if transaction.quoted_weight > 0 else 0
        
        if price_per_kg < avg_price * 0.7:
            anomalies.append(Anomaly(
                severity="MEDIUM",
                reason="Quoted price significantly below market average",
                expected_range=f"Rs.{avg_price * 0.7:.0f}-{avg_price * 1.3:.0f}/kg",
                actual_value=f"Rs.{price_per_kg:.0f}/kg"
            ))
        
        if price_per_kg > avg_price * 1.3:
            anomalies.append(Anomaly(
                severity="LOW",
                reason="Quoted price above market average (may indicate premium material)",
                expected_range=f"Rs.{avg_price * 0.7:.0f}-{avg_price * 1.3:.0f}/kg",
                actual_value=f"Rs.{price_per_kg:.0f}/kg"
            ))
    
    # Weight discrepancy check
    if transaction.final_weight and transaction.quoted_weight:
        discrepancy = abs(transaction.final_weight - transaction.quoted_weight) / transaction.quoted_weight
        if discrepancy > 0.2:
            anomalies.append(Anomaly(
                severity="HIGH" if discrepancy > 0.4 else "MEDIUM",
                reason="Weight discrepancy between quoted and final weight",
                expected_range=f"Within 20% of {transaction.quoted_weight}kg",
                actual_value=f"{transaction.final_weight}kg ({discrepancy*100:.0f}% difference)"
            ))
    
    # Speed check
    if transaction.completed_at and transaction.created_at:
        duration = (transaction.completed_at - transaction.created_at).total_seconds()
        if duration < 600:  # Less than 10 minutes
            anomalies.append(Anomaly(
                severity="LOW",
                reason="Transaction completed unusually fast",
                expected_range="Typically > 10 minutes",
                actual_value=f"{duration / 60:.1f} minutes"
            ))
    
    return anomalies

def get_flagged_transactions(db: Session) -> list:
    """Get all transactions that have anomalies."""
    transactions = db.query(Transaction).all()
    flagged = []
    
    for txn in transactions:
        anomalies = check_transaction(db, txn)
        if anomalies:
            flagged.append({
                "transaction_id": txn.id,
                "handover_reference": txn.handover_reference,
                "transaction_status": txn.transaction_status,
                "quoted_price": txn.quoted_price,
                "final_price": txn.final_price,
                "quoted_weight": txn.quoted_weight,
                "final_weight": txn.final_weight,
                "anomalies": [a.to_dict() for a in anomalies],
            })
    
    return flagged
