# AI Approach

## Material Classification

### Interface

```python
class MaterialClassifier:
    def classify(self, image_data: bytes) -> ClassificationResult:
        pass

class ClassificationResult:
    category: str           # e.g., "PCB"
    category_id: str        # UUID of the material category
    confidence: float       # 0.0 to 1.0
    alternatives: list      # [{category, confidence}]
```

### Current Implementation: Demo Classifier

The MVP ships with a demo classifier that returns deterministic results. This is clearly documented and never misrepresented as a trained model.

How the demo classifier works:

1. If the image filename contains a material keyword (e.g., "pcb", "cable", "battery"), it returns that material with 0.85 confidence
2. If no keyword match, it returns "PCB" as the default with 0.72 confidence
3. Always provides 2 alternative suggestions with lower confidence

This approach is honest about capability while demonstrating the UX flow. The user always sees a confirmation screen: "Detected: PCB. Is this correct? YES / CHANGE"

### Production Path

The classifier interface is designed for replacement. A production implementation would:

1. Accept an image (camera or gallery)
2. Resize to model input dimensions
3. Run inference against a trained classification model
4. Return top-3 predictions with calibrated confidence scores

Candidate approaches:
- Fine-tuned MobileNet or EfficientNet on e-waste image dataset
- On-device inference via TensorFlow Lite for offline classification
- Server-side inference via TorchServe for higher accuracy

The key constraint: no suitable public dataset of Indian informal e-waste exists. Building a reliable classifier requires field-collected images from actual kabadiwalas, properly labeled by material experts.

We don't fake this. The demo classifier is clearly a demo.

## Price Estimation

### Interface

```python
class PriceEstimator:
    def estimate(self, material_id, location, weight, condition) -> PriceEstimate

class PriceEstimate:
    min_price: float
    max_price: float
    reference_price: float      # per kg
    total_reference_price: float
    confidence: str             # HIGH, MEDIUM, LOW
    data_points_used: int
    trend: str                  # UP, DOWN, STABLE
    limited_data: bool
```

### Current Implementation

Uses actual price observation records from the database. The estimation logic:

1. Query price observations for the material within the location area
2. Filter to recent period (default 30 days)
3. Calculate: median, 25th percentile (min), 75th percentile (max)
4. Apply condition adjustment: GOOD (1.0x), FAIR (0.85x), POOR (0.7x), MIXED (0.8x)
5. Apply weight bonus: >50kg (+5%), >100kg (+10%)
6. Determine trend by comparing recent median to older median
7. Set confidence based on data point count: <5 = LOW, <15 = MEDIUM, 15+ = HIGH
8. Flag limited_data when fewer than 5 observations

The seeded demo data includes 30+ observations per material spanning 90 days, so the price engine produces realistic estimates with reasonable confidence.

All seeded data is marked with `source = "SEEDED_DEMO_DATA"`. The UI never claims these are live market prices.

### Production Path

Real price intelligence would incorporate:
- Live recycler quotes
- Historical platform transaction prices
- Regional price indices from industry reports
- Seasonal adjustment factors
- Supply/demand signals from the platform itself

## Anomaly Detection

### How it works

The anomaly detector flags suspicious patterns in transactions:

1. **Low offer**: If an offer is more than 20% below the local median price for that material, flag it. Shows the expected range and actual offer.

2. **Weight discrepancy**: If final weight differs from estimated weight by more than 25%, flag for review.

3. **Pattern detection**: If a recycler consistently offers below-market prices (3+ transactions below 80% of median), flag for admin review.

These are flags, not blocks. The collector sees a warning. The admin sees the flag. The transaction can still proceed.

### Production Path

More sophisticated detection would add:
- Temporal anomalies (unusual transaction times)
- Volume anomalies (sudden spikes in recycler purchases)
- Price manipulation detection
- Cross-collector comparison

## Recycler Matching

### Scoring Formula

```
Score = (material_compat * 0.30) +
        (auth_score      * 0.25) +
        (price_score     * 0.20) +
        (distance_score  * 0.15) +
        (pickup_score    * 0.10)
```

Components:
- **Material compatibility** (30%): Does the recycler accept this material? Binary, but weighted highest.
- **Authorization** (25%): VERIFIED = 1.0, PENDING = 0.5, UNKNOWN = 0.2, EXPIRED = 0.1
- **Price** (20%): Recycler's offered rate relative to market median. Higher rate = higher score.
- **Distance** (15%): Inverse of distance. Closer = better. Capped at service radius.
- **Pickup** (10%): Boolean bonus for offering pickup service.

The score is presented as a whole number (0-100) labeled "MATCH SCORE", not as a probability or scientific measure.

## Smart Aggregation

### Logic

1. Find lots with the same material category within a geographic radius
2. Sum total weight
3. Calculate individual price (median for small quantities)
4. Calculate group price (median + volume bonus)
5. Show the collector the difference

Volume bonuses are real (recyclers prefer bulk) but the specific numbers are demo estimates. The UI labels the improved rate as "Potential Group Price" to avoid guaranteeing it.
