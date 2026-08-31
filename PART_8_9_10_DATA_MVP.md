# PART 8: DATA STRATEGY

We built this data strategy around what a student team can actually pull off. We separate data into what we can grab today, what we have to fake, what we need a partner for, and what we skip entirely for the MVP.

## Material Identification
*   **Fields:** Image (RGB), category label, material sub-type.
*   **Sources:** Open datasets like TrashNet and TACO. User uploads later on.
*   **Collection method:** Scrape academic datasets. Capture real photos at local Indian scrap yards to build a raw baseline.
*   **Size:** 5,000 to 10,000 images per category for initial training.
*   **Risks:** Western trash datasets look nothing like Indian street waste. The model will fail in the real world if we rely only on Kaggle.
*   **Strategy:** Get now (open datasets) + Generate (heavy data augmentation on a small set of local photos) + Skip (perfect bounding boxes).

## Price Prediction
*   **Fields:** Material type, date, city zone, price per kg, volume trends.
*   **Sources:** Historical scrap rates, local trader interviews.
*   **Collection method:** Manual scraping of wholesale scrap market prices. Occasional manual entry.
*   **Size:** Daily price points across 10-15 material categories over one year.
*   **Risks:** Scrap prices are highly informal and localized. There is no Bloomberg terminal for street scrap.
*   **Strategy:** Generate (use simulated historical data for demo) + Skip (live market API integration).

## Recycler Recommendation
*   **Fields:** Recycler ID, location coordinates, accepted materials, capacity, pricing tier.
*   **Sources:** Google Maps Places API, local NGO directories.
*   **Collection method:** Map scraping for terms like "scrap dealers" and "kabadhiwala" near target MVP zones.
*   **Size:** 100 completely vetted local recyclers.
*   **Risks:** Contact info rots quickly. Capacity limits are never recorded online.
*   **Strategy:** Partner (local NGOs for vetted lists) + Get now (Google Maps).

## Fraud Detection
*   **Fields:** User ID, lot weight, expected vs reported price, GPS spoofing flags.
*   **Sources:** App usage telemetry.
*   **Collection method:** Backend logging of transaction anomalies.
*   **Size:** Megabytes of log data.
*   **Risks:** False positives alienate early users. A student team lacks the time to tune this.
*   **Strategy:** Skip entirely. Implement basic hard limits on weight/price ratios instead.


# PART 9: MVP DEFINITION

This definition strips away the fat. It respects the constraints of a student team schedule.

## Priority Matrix
*   **MUST HAVE:** AI material classification (the core hook), lot creation, basic recycler matching by distance, static price estimates.
*   **SHOULD HAVE:** User auth, historical price charts, offline mode just for viewing saved lots.
*   **CAN WAIT:** Real-time live market prices, in-app chat, route optimization for recyclers.
*   **REMOVE ENTIRELY:** Complex ML fraud detection, digital payment gateway integration (assume cash on delivery), multi-language voice dictation.

## User Journey Trace
1.  **Open:** User launches the app.
    *   *Tech:* Flutter Home Screen.
2.  **Classify:** User snaps a photo of an item.
    *   *Tech:* Flutter camera plugin. FastAPI backend receives it. PyTorch/TensorFlow classifier demo service returns a label.
3.  **Lot:** User adds the classified item to a virtual lot and enters a weight estimate.
    *   *Tech:* Flutter Lots Screen. SQLite (local) syncs to PostgreSQL (remote).
4.  **Match:** User hits "Find Recyclers". App ranks nearby buyers.
    *   *Tech:* PostGIS or simple Haversine distance on the FastAPI backend. Demo matching service applies rules.
5.  **Handover:** App displays recycler contact and location. User manages the physical handover offline.
    *   *Tech:* Flutter Sell Screen. Google Maps launcher intent.
6.  **Pay:** User marks the lot as sold and logs the cash they received.
    *   *Tech:* FastAPI backend update. Simple CRUD operation.


# PART 10: IMPLEMENTATION GAP ANALYSIS

The current codebase contains four Flutter screens (Home, Lots, Prices, Sell), a FastAPI backend, and a few demo services (classifier, price engine, matching). Here is what we actually have to build next.

| Component | What needs building | Priority |
| :--- | :--- | :--- |
| **Frontend** | Camera integration for live photo capture. Connect the static demo classification UI to the actual API. | High |
| **Frontend** | State management (Riverpod or Provider) to persist the lot object across the different screens. | High |
| **Backend** | Error handling for AI services. The backend crashes if the user uploads a blurry image. | High |
| **Database** | Actual database migrations and schema setup. We exist on demo scripts right now. | High |
| **AI** | Deploy the model behind a real inference server rather than triggering a local Python script. | Medium |
| **Auth** | Login and signup flow. JWT middleware on the backend. User tables. | Medium |
| **Location** | Geolocation plugin to get real user coordinates for the matching engine. | Medium |
| **Offline** | Local SQLite caching so users can build lots without network access. | Low |
| **Voice** | Speech-to-text input for quick item descriptions. | Low |
| **Notifications** | Push notifications to alert users about price drops. | Low |
| **Admin** | Dashboard to view system metrics and inject mock recyclers into the database. | Low |
