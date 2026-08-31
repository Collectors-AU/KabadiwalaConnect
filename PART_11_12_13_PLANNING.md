# Part 11: Dependency graph

Building KabadiwalaConnect requires strict ordering. The core data schema blocks everything else.

The main critical path moves from schema to auth, then to the core API, and finally to the mobile app foundation. The database schema must be finished first. Auth then blocks user profiles and secured routes. The core API blocks the mobile views. Offline sync blocks the field app. The AI classification pipeline requires image upload infrastructure.

Certain tasks can run in parallel. The frontend team can build UI components while the backend team designs the database. Machine learning engineers can train the classification model on a static dataset independently of the main API. A single developer can prototype the voice-to-text script while the rest of the app is built.

# Part 12: Development roadmap

### Phase 0: Foundation
This phase establishes the project architecture. The team will set up repositories, define the database schema, and configure automated deployments. This requires no previous work. The output is a working local environment and applied database migrations.

### Phase 1: Core MVP
The focus shifts to basic functionality. Users need authentication, routing, pickup scheduling, and a directory of local kabadiwalas. This relies entirely on Phase 0 being complete. The result will be a working API and the primary mobile screens for booking a pickup.

### Phase 2: First AI
We introduce image-based waste classification and price estimations here. The application must already support image uploads from Phase 1. Delivery includes the model endpoint and the user interface for taking photos and displaying price estimates.

### Phase 3: Offline and voice
Field workers need the app to function in low connectivity areas. Local data caching and voice command scheduling solve this. This phase requires the core API and AI integration to be stable. The deliverables are a local database architecture and a speech-to-text endpoint for vernacular parsing.

### Phase 4: Verification
This phase secures the platform. We add fraud prevention, collector weight verification, and GPS tracking. It depends on the offline capabilities and core scheduling. We will deliver live location tracking and a QR code handshake system.

### Phase 5: Recycler network
The final phase expands into B2B. Kabadiwalas get a marketplace to sell sorted waste in bulk to large recycling facilities. This requires the verification flow to ensure clean data. The team will ship a web dashboard for recyclers and bulk inventory management.

# Part 13: 48-hour hackathon plan (SIH 2026)

This schedule assumes a team of four to six people. Sleep happens during the 8 to 16 and 24 to 36 blocks.

### Hour 0 to 4
Initialize repositories and finalize the database schema. Use an existing backend service like Supabase to get auth and the database for free. Build the main API route for scheduling waste pickups.

### Hour 4 to 8
The frontend group builds the scheduling screen. The backend group integrates the chosen vision API for waste classification. Connect the mobile client to the staging database.

### Hour 8 to 16
Half the team sleeps. The others implement the kabadiwala interface and GPS tracking. Write scripts to flood the database with dummy collectors so the map looks populated.

### Hour 16 to 24
Swap sleepers. Implement the voice-to-text feature for vernacular commands. Polish the user flow from opening the app to confirming a pickup request.

### Hour 24 to 36
Sleep in shifts. Build the verification process. Ensure the QR code handshake works instantly on physical phones.

### Hour 36 to 44
Stop writing new features. Fix interface glitches and record the demo video. Write a clear project readme. Deploy the backend to a stable host like Vercel.

### Hour 44 to 48
Practice the pitch. Prepare answers for the judges. Load test the live app so it survives five people clicking around at the same time.

### What not to build
Skip building a custom authentication system. Use a provider. Ignore the admin dashboard. Just edit the database directly if judges ask to see an admin view. Do not support real payments. Hardcode a fake UPI success screen. Leave out the Phase 5 recycler network. Focus only on the consumer and collector experience.
