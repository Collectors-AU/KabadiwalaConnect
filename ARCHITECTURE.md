# Architecture

## System Overview

```
┌─────────────────────────────────┐
│         Mobile App              │
│   React Native + Expo + TS      │
│                                 │
│  ┌─────────┐  ┌──────────────┐  │
│  │ SQLite  │  │  Sync Queue  │  │
│  │ (local) │  │              │  │
│  └─────────┘  └──────┬───────┘  │
│                      │          │
└──────────────────────┼──────────┘
                       │
                   HTTP/REST
                       │
┌──────────────────────┼──────────┐
│         FastAPI Backend         │
│                                 │
│  ┌───────────┐ ┌─────────────┐  │
│  │  Services │ │  Classifier │  │
│  │  Price    │ │  (demo/AI)  │  │
│  │  Matcher  │ │             │  │
│  │  Anomaly  │ └─────────────┘  │
│  └───────────┘                  │
│                                 │
│  ┌─────────────────────────┐    │
│  │   SQLAlchemy + SQLite   │    │
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

## Mobile Architecture

The mobile app follows a feature-based structure with clear separation between UI, data access, and business logic.

### Layers

1. **Screens** - React Native components, one per screen
2. **Components** - Reusable UI components (Button, Card, Badge, etc.)
3. **Services** - API client, voice service
4. **Database** - SQLite schema, repository, sync queue
5. **Context** - Global state (user, language, connectivity)
6. **i18n** - Translation files (en, hi, mr)

### Navigation

Bottom tabs: Home, Lots, Prices, Buyers, More

Each tab has its own stack navigator for drill-down screens.

### Offline Strategy

Local SQLite stores:
- Collector profile
- Material categories (cached from server)
- Recent prices (cached)
- Recyclers (cached)
- Lots (created offline or synced)
- Sync queue (pending uploads)

Every locally created object gets a `syncStatus` field:
- `LOCAL_ONLY` - Created offline, not yet sent
- `PENDING_SYNC` - Queued for upload
- `SYNCED` - Confirmed by server
- `SYNC_FAILED` - Upload failed, will retry

### Sync Flow

```
Connectivity detected
       ↓
Read sync queue
       ↓
POST /api/sync with batch
       ↓
Server processes and returns results
       ↓
Update local records with server IDs
       ↓
Mark as SYNCED
```

## Backend Architecture

### Layers

1. **API routes** - FastAPI route handlers, thin, delegate to services
2. **Schemas** - Pydantic models for request/response validation
3. **Services** - Business logic (pricing, matching, classification, anomaly)
4. **Models** - SQLAlchemy ORM models
5. **Repositories** - Data access layer
6. **Seed** - Demo data population

### Key Services

#### PriceEngine
Calculates fair value using price observations. Applies condition adjustments and weight bonuses. Returns min/max/reference with confidence based on data point count.

#### MaterialClassifier
Pluggable interface. The demo classifier returns deterministic results based on filename patterns. A real implementation would accept an image and run inference against a trained model.

#### RecyclerMatcher
Scores recyclers on: material compatibility (30%), authorization (25%), price competitiveness (20%), distance (15%), pickup availability (10%).

#### AnomalyDetector
Flags transactions where the offer price is more than 20% below local median, weight differs significantly from estimate, or the recycler has a pattern of low offers.

#### AggregationService
Finds nearby lots with the same material category and calculates the premium from combining volumes. Uses a stepped bonus: >50kg +5%, >100kg +10%.

## Database

SQLite for both mobile and backend. Single-file database keeps deployment simple for demo.

Production path: swap SQLite for PostgreSQL on the backend, keep SQLite on mobile.

### Tables

- users
- material_categories
- lots
- recyclers
- price_observations
- offers
- transactions
- traceability_events
- recycler_demands
- aggregation_groups
- aggregation_members

## Authentication

Simple demo auth for MVP. POST to /api/auth/demo-login with role and name, receive a token (user ID). Token passed as Bearer in subsequent requests.

No OTP, no OAuth, no password hashing. Authentication should not block the demo.

## Image Storage

MVP uses filesystem storage under `./uploads/`. The storage interface is designed for replacement with S3/GCS in production.

## Decisions

1. **SQLite over PostgreSQL**: Simpler setup for demo environments. One fewer service to install.
2. **Demo classifier over real ML**: Honest about capability. Interface is ready for a real model.
3. **No WebSocket**: Polling and manual refresh for MVP. Simpler, works offline.
4. **No microservices**: Single API process. Appropriate scale for MVP.
5. **Expo over bare React Native**: Faster development, easier demo setup with Expo Go.
