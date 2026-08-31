# API Reference

Base URL: `http://localhost:8000/api`

All endpoints return JSON. Authentication uses Bearer token (user ID from demo-login).

## Authentication

### POST /api/auth/demo-login

Login with demo credentials.

**Request:**
```json
{
  "role": "COLLECTOR",
  "display_name": "Ramesh Kumar",
  "preferred_language": "hi"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "role": "COLLECTOR",
    "display_name": "Ramesh Kumar",
    "preferred_language": "hi",
    "operating_area": "Dharavi, Mumbai"
  },
  "token": "user-uuid"
}
```

## Materials

### GET /api/materials

List all material categories.

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "PCB",
    "display_name_en": "Circuit Board (PCB)",
    "display_name_hi": "पीसीबी",
    "display_name_mr": "पीसीबी",
    "description": "Printed Circuit Boards from electronics",
    "hazard_level": "MEDIUM",
    "icon": "🔧"
  }
]
```

## Lots

### POST /api/lots

Create a new lot.

**Request:**
```json
{
  "collector_id": "uuid",
  "material_category_id": "uuid",
  "approximate_weight": 18.0,
  "condition": "GOOD",
  "source_type": "COMMERCIAL",
  "photo_urls": ["photo1.jpg"],
  "location_lat": 19.0760,
  "location_lng": 72.8777,
  "location_name": "Dharavi, Mumbai"
}
```

### GET /api/lots?collector_id=X&status=Y

List lots with optional filters.

### GET /api/lots/{id}

Get single lot with full details.

### PUT /api/lots/{id}

Update lot fields.

### POST /api/lots/{id}/classify

Classify material from lot photos.

**Response:**
```json
{
  "category": "PCB",
  "category_id": "uuid",
  "confidence": 0.85,
  "alternatives": [
    {"category": "LCD", "confidence": 0.10}
  ]
}
```

### GET /api/lots/{id}/estimate

Get price estimate for a lot.

**Response:**
```json
{
  "min_price": 2790.0,
  "max_price": 3150.0,
  "reference_price_per_unit": 162.0,
  "total_reference_price": 2916.0,
  "confidence": "HIGH",
  "data_points_used": 37,
  "trend": "UP",
  "weight": 18.0,
  "material": "PCB",
  "condition_adjustment": 1.0,
  "weight_bonus": 0.0,
  "limited_data": false
}
```

## Prices

### GET /api/prices

Current prices for all materials.

**Response:**
```json
[
  {
    "material_id": "uuid",
    "material_name": "PCB",
    "current_price": 162.0,
    "min_price": 140.0,
    "max_price": 180.0,
    "trend": "UP",
    "data_points": 37,
    "unit": "KG"
  }
]
```

### GET /api/prices/trend?material_id=X&period=30d

Price trend data.

**Response:**
```json
{
  "material": "PCB",
  "period": "30d",
  "data_points": [
    {"date": "2024-01-01", "price": 155.0},
    {"date": "2024-01-02", "price": 158.0}
  ],
  "trend": "UP",
  "change_percent": 4.5,
  "min": 148.0,
  "max": 172.0,
  "average": 160.0
}
```

## Recyclers

### GET /api/recyclers

List all recyclers.

### GET /api/recyclers/matches?lot_id=X

Get matched recyclers for a specific lot.

**Response:**
```json
[
  {
    "recycler": { "...recycler object..." },
    "match_score": 94,
    "price_per_unit": 168.0,
    "total_price": 3024.0,
    "distance_km": 12.3,
    "reasons": [
      "Accepts PCB",
      "Authorized",
      "₹168/kg",
      "Pickup available",
      "Within service area"
    ]
  }
]
```

## Demand

### GET /api/demand

Active recycler demands.

### POST /api/demand

Create recycler demand.

**Request:**
```json
{
  "recycler_id": "uuid",
  "material_category_id": "uuid",
  "required_weight": 100.0,
  "offered_price": 170.0,
  "pickup_available": true,
  "service_radius_km": 25.0,
  "valid_until": "2024-02-01T00:00:00Z"
}
```

## Aggregation

### GET /api/aggregation/opportunities?collector_id=X

Find aggregation opportunities.

**Response:**
```json
[
  {
    "group_id": "uuid",
    "material": "PCB",
    "your_weight": 18.0,
    "group_weight": 92.0,
    "member_count": 4,
    "individual_price": 155.0,
    "group_price": 168.0,
    "your_additional_value": 234.0,
    "lots": ["uuid1", "uuid2", "uuid3"]
  }
]
```

### POST /api/aggregation/{group_id}/join

Join an aggregation group.

**Request:**
```json
{
  "lot_id": "uuid",
  "collector_id": "uuid"
}
```

## Offers

### POST /api/offers

Create offer on a lot (recycler action).

**Request:**
```json
{
  "lot_id": "uuid",
  "recycler_id": "uuid",
  "price_per_unit": 168.0,
  "notes": "Pickup available tomorrow"
}
```

### GET /api/offers?lot_id=X

List offers for a lot.

### POST /api/offers/{id}/accept

Accept an offer (collector action).

### POST /api/offers/{id}/reject

Reject an offer.

## Handover

### POST /api/handover

Initiate handover, creates a transaction.

**Request:**
```json
{
  "lot_id": "uuid",
  "offer_id": "uuid",
  "collection_location": "Dharavi, Mumbai",
  "handover_location": "GreenTech Facility, Navi Mumbai"
}
```

### POST /api/handover/{transaction_id}/confirm

Confirm handover with final details.

**Request:**
```json
{
  "final_weight": 17.8,
  "handover_photo_url": "handover_photo.jpg",
  "final_price": 2990.4
}
```

## Payments

### POST /api/payments

Record payment for a transaction.

**Request:**
```json
{
  "transaction_id": "uuid",
  "payment_method": "CASH",
  "amount": 2990.4,
  "payment_reference": null
}
```

## Earnings

### GET /api/earnings?collector_id=X

Earnings summary.

**Response:**
```json
{
  "total_earnings": 15420.0,
  "this_month": 5240.0,
  "transaction_count": 8,
  "transactions": [
    {
      "id": "uuid",
      "material": "PCB",
      "weight": 17.8,
      "amount": 2990.4,
      "date": "2024-01-15",
      "recycler": "GreenTech"
    }
  ]
}
```

## Passports

### GET /api/passports/{lot_id}

Material passport with traceability events.

**Response:**
```json
{
  "lot_id": "uuid",
  "material": "PCB",
  "weight": 17.8,
  "collector": "Ramesh Kumar",
  "events": [
    {
      "event_type": "COLLECTED",
      "timestamp": "2024-01-15T10:00:00Z",
      "location": "Dharavi, Mumbai",
      "actor": "Ramesh Kumar"
    },
    {
      "event_type": "HANDOVER",
      "timestamp": "2024-01-16T14:00:00Z",
      "location": "GreenTech Facility",
      "actor": "GreenTech",
      "reference": "KAB-TXN-A1B2C"
    }
  ],
  "awaiting": ["PROCESSING", "RECYCLED"]
}
```

## Verification

### GET /api/verify/{reference}

Public verification by transaction reference.

**Response:**
```json
{
  "verified": true,
  "reference": "KAB-TXN-A1B2C",
  "material": "PCB",
  "weight": 17.8,
  "collection_date": "2024-01-15",
  "handover_date": "2024-01-16",
  "recycler": "GreenTech E-Waste Solutions",
  "recycler_authorized": true,
  "status": "COMPLETED",
  "events": ["COLLECTED", "LISTED", "OFFER_ACCEPTED", "HANDOVER", "PAYMENT"]
}
```

## Sync

### POST /api/sync

Batch sync offline-created data.

**Request:**
```json
{
  "lots": [
    {
      "local_id": "local-uuid",
      "material_category_id": "uuid",
      "approximate_weight": 12.0,
      "condition": "FAIR",
      "photo_urls": [],
      "location_lat": 19.0760,
      "location_lng": 72.8777,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

**Response:**
```json
{
  "synced_lots": [
    {
      "local_id": "local-uuid",
      "server_id": "server-uuid",
      "status": "SYNCED"
    }
  ],
  "failed": [],
  "server_updates": {
    "prices": [...],
    "recyclers": [...]
  }
}
```

## Admin

### GET /api/admin/metrics

System metrics.

**Response:**
```json
{
  "total_lots": 45,
  "total_weight_kg": 892.5,
  "total_transaction_value": 142500.0,
  "completed_transactions": 28,
  "pending_payments": 3,
  "flagged_transactions": 2,
  "verified_recyclers": 3,
  "active_collectors": 12
}
```

### GET /api/admin/transactions

All transactions with optional filters.

### GET /api/admin/flagged

Transactions flagged by anomaly detection.
