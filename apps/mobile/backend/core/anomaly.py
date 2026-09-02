import numpy as np
from sklearn.ensemble import IsolationForest

class AnomalyDetector:
    def __init__(self):
        # IsolationForest for outlier detection
        # contamination is the expected proportion of outliers in the data set
        self.model = IsolationForest(contamination=0.05, random_state=42)
        self.is_trained = False
        
        # We need some baseline data to train the model initially.
        # Features: [Weight, Value, Category_ID, Unit_Price]
        # Unit_Price = Value / Weight
        self._train_baseline()
        
    def _train_baseline(self):
        # Synthetic baseline data representing normal transactions
        # [Weight(kg), Value(INR), Category_ID, Unit_Price(INR/kg)]
        # Copper: ~425 INR/kg
        # PCB: ~208 INR/kg
        # Battery: ~83 INR/kg
        
        baseline_data = [
            [5.0, 2125.0, 1, 425.0],    # Normal copper
            [10.0, 4250.0, 1, 425.0],   # Normal copper
            [2.5, 520.0, 2, 208.0],     # Normal PCB
            [8.0, 1664.0, 2, 208.0],    # Normal PCB
            [20.0, 1660.0, 3, 83.0],    # Normal battery
            [50.0, 4150.0, 3, 83.0],    # Normal battery
            # Add some variations
            [5.5, 2300.0, 1, 418.18],
            [12.0, 4900.0, 1, 408.33],
            [3.0, 600.0, 2, 200.0],
            [15.0, 1200.0, 3, 80.0]
        ]
        
        X = np.array(baseline_data)
        self.model.fit(X)
        self.is_trained = True
        
    def is_transaction_anomalous(self, weight: float, value: float, cat_id: int) -> bool:
        """
        Returns True if the transaction is considered anomalous.
        """
        if not self.is_trained:
            return False
            
        if weight <= 0:
            return True # Unrealistic weight
            
        unit_price = value / weight
        
        # [Weight, Value, Category_ID, Unit_Price]
        features = np.array([[weight, value, float(cat_id), unit_price]])
        
        # predict returns 1 for inliers, -1 for outliers
        prediction = self.model.predict(features)
        
        return prediction[0] == -1

# Singleton instance
detector = AnomalyDetector()
