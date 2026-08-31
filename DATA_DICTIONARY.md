# Data Dictionary

## Users

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| role | string | COLLECTOR, RECYCLER, ADMIN |
| display_name | string | User's display name |
| preferred_language | string | en, hi, mr |
| operating_area | string | Geographic area of operation |
| created_at | datetime | Account creation timestamp |
| updated_at | datetime | Last update timestamp |

## Material Categories

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | string | Internal name: CRT, LCD, PCB, CABLE, BATTERY, MOTOR, MAGNET_ASSEMBLY, MIXED_PLASTIC |
| display_name_en | string | English display name |
| display_name_hi | string | Hindi display name |
| display_name_mr | string | Marathi display name |
| description | string | Material description |
| hazard_level | string | LOW, MEDIUM, HIGH |
| icon | string | Emoji icon for UI |

## Lots

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| collector_id | UUID FK | Reference to collector user |
| material_category_id | UUID FK | Reference to material category |
| description | string | Optional description |
| photo_urls | JSON text | Array of photo URLs |
| approximate_weight | float | Estimated weight in kg |
| condition | string | GOOD, FAIR, POOR, MIXED |
| source_type | string | HOUSEHOLD, COMMERCIAL, INDUSTRIAL, MIXED |
| estimated_min_value | float | Minimum estimated value in INR |
| estimated_max_value | float | Maximum estimated value in INR |
| estimated_price_per_unit | float | Estimated price per kg in INR |
| location_lat | float | Collection latitude |
| location_lng | float | Collection longitude |
| location_name | string | Human-readable location name |
| status | string | See Lot Statuses below |
| sync_status | string | LOCAL_ONLY, PENDING_SYNC, SYNCED, SYNC_FAILED |
| created_at | datetime | Creation timestamp |
| updated_at | datetime | Last update timestamp |

### Lot Statuses

| Status | Description |
|--------|-------------|
| DRAFT | Created but not ready for sale |
| READY_FOR_SALE | Listed and available for offers |
| OFFERED | Has received at least one offer |
| ACCEPTED | Collector accepted an offer |
| PICKUP_SCHEDULED | Recycler scheduled pickup |
| HANDED_OVER | Physical handover completed |
| PAYMENT_PENDING | Awaiting payment |
| COMPLETED | Transaction fully completed |
| CANCELLED | Cancelled by either party |

## Recyclers

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID FK | Associated user account (nullable) |
| name | string | Facility/business name |
| facility_location | string | Address description |
| latitude | float | Facility latitude |
| longitude | float | Facility longitude |
| materials_accepted | JSON text | Array of material category names |
| authorization_status | string | VERIFIED, PENDING_VERIFICATION, EXPIRED, UNKNOWN |
| authorization_reference | string | Authorization document reference |
| contact | string | Contact information |
| offered_rates | JSON text | Object mapping material name to rate per kg |
| pickup_available | boolean | Whether recycler offers pickup |
| service_radius_km | float | Maximum service distance in km |
| created_at | datetime | Record creation timestamp |
| updated_at | datetime | Last update timestamp |

## Price Observations

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| material_category_id | UUID FK | Material being priced |
| location | string | Observation location |
| observed_at | datetime | When the price was observed |
| buying_price | float | Price at which material is bought (INR/kg) |
| selling_price | float | Price at which material is sold (INR/kg) |
| unit | string | Always KG |
| recycler_id | UUID FK | Recycler providing the quote (nullable) |
| source | string | FIELD_ENTRY, RECYCLER_QUOTE, PLATFORM_TRANSACTION, SEEDED_DEMO_DATA |
| quality | string | GOOD, FAIR, POOR |

## Offers

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| lot_id | UUID FK | Lot being offered on |
| recycler_id | UUID FK | Offering recycler |
| price_per_unit | float | Offered price per kg in INR |
| total_price | float | Total offered price in INR |
| status | string | PENDING, ACCEPTED, REJECTED, EXPIRED, WITHDRAWN |
| valid_until | datetime | Offer expiration (nullable) |
| notes | string | Optional notes |
| created_at | datetime | Offer creation timestamp |
| updated_at | datetime | Last update timestamp |

## Transactions

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| lot_id | UUID FK | Associated lot |
| collector_id | UUID FK | Selling collector |
| recycler_id | UUID FK | Buying recycler |
| offer_id | UUID FK | Accepted offer (nullable) |
| quoted_price | float | Originally quoted total price in INR |
| final_price | float | Final agreed price in INR (nullable until handover) |
| quoted_weight | float | Originally stated weight in kg |
| final_weight | float | Verified weight at handover in kg (nullable until handover) |
| collection_location | string | Where material was collected |
| handover_location | string | Where handover occurred |
| handover_photo_url | string | Photo taken at handover |
| handover_reference | string | Unique reference like KAB-TXN-XXXXX |
| payment_method | string | CASH, UPI, BANK_TRANSFER (nullable until payment) |
| payment_status | string | PENDING, PAID, FAILED, REFUNDED |
| payment_reference | string | UPI/bank reference number (nullable) |
| transaction_status | string | See Transaction Statuses below |
| created_at | datetime | Transaction creation timestamp |
| completed_at | datetime | Completion timestamp (nullable) |

### Transaction Statuses

| Status | Description |
|--------|-------------|
| INITIATED | Offer accepted, transaction started |
| PICKUP_SCHEDULED | Recycler scheduled pickup |
| IN_TRANSIT | Material being transported |
| HANDED_OVER | Physical handover confirmed |
| PAYMENT_PENDING | Handover done, payment not yet received |
| COMPLETED | Fully completed with payment |
| CANCELLED | Cancelled |
| DISPUTED | Under dispute |

## Traceability Events

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| lot_id | UUID FK | Associated lot |
| event_type | string | See Event Types below |
| location | string | Where the event occurred |
| latitude | float | Event latitude |
| longitude | float | Event longitude |
| timestamp | datetime | When the event occurred |
| photo_url | string | Associated photo (nullable) |
| actor_id | UUID FK | Who performed the action |
| reference_number | string | Any reference number (nullable) |
| metadata | JSON text | Additional structured data |

### Event Types

| Type | Description |
|------|-------------|
| COLLECTED | Material collected by collector |
| LISTED | Lot listed for sale |
| OFFER_RECEIVED | Offer received from recycler |
| OFFER_ACCEPTED | Collector accepted offer |
| PICKUP_STARTED | Recycler started pickup |
| HANDOVER | Physical handover completed |
| PAYMENT | Payment recorded |
| RECEIVED_BY_RECYCLER | Recycler confirmed receipt |
| PROCESSING | Material being processed |
| RECYCLED | Material recycled |

## Recycler Demands

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| recycler_id | UUID FK | Demanding recycler |
| material_category_id | UUID FK | Requested material |
| required_weight | float | How much material needed in kg |
| offered_price | float | Price offered per kg in INR |
| pickup_available | boolean | Whether pickup is offered |
| service_radius_km | float | Service area radius |
| valid_until | datetime | When the demand expires |
| status | string | ACTIVE, FULFILLED, EXPIRED, CANCELLED |
| created_at | datetime | Creation timestamp |

## Aggregation Groups

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| material_category_id | UUID FK | Material being aggregated |
| status | string | FORMING, READY, MATCHED, COMPLETED, CANCELLED |
| total_weight | float | Combined weight in kg |
| individual_price_estimate | float | Per-kg price for individual lots |
| group_price_estimate | float | Per-kg price for combined lot |
| location_lat | float | Group center latitude |
| location_lng | float | Group center longitude |
| created_at | datetime | Creation timestamp |

## Aggregation Members

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| group_id | UUID FK | Aggregation group |
| lot_id | UUID FK | Member lot |
| collector_id | UUID FK | Lot owner |
| joined_at | datetime | When the collector joined |
