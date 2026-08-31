# Demo Script

This script walks through the complete Kabadiwala Connect demo in about 8-10 minutes.

## Setup

1. Start the backend: `cd apps/api && python -m uvicorn app.main:app --reload --port 8000`
2. Start the mobile app: `cd apps/mobile && npx expo start`
3. Open in Expo Go or Android emulator

## Demo Flow

### Part 1: Language and Login (1 min)

1. Open the app
2. Notice the DEMO MODE banner at the top
3. Select Hindi as language
4. App greets: "नमस्ते, Ramesh"
5. Point out the large, simple interface designed for field workers

### Part 2: Check Today's Prices (1 min)

1. Tap "आज के भाव" (Today's Prices)
2. Show the price cards for each material
3. Tap PCB to see the price trend
4. Switch between 7 day, 30 day, 90 day views
5. Point out the trend arrow and data point count
6. Note: "These are seeded demo prices clearly marked as demo data"

### Part 3: Create a Lot - The Core Flow (3 min)

1. Go back to Home
2. Tap the big green "कबाड़ बेचें" (Sell Scrap) button
3. Take a photo or select from gallery
4. System identifies: "PCB" with classification result
5. Tap "हाँ" (Yes) to confirm
6. Enter weight: tap "18" on the keypad or quick-select
7. See the price estimate:
   - Fair range: ₹2,790 - ₹3,150
   - Reference: ₹162/kg
   - Trend: UP
   - Data points: 37
8. Tap "खरीदार खोजें" (Find Buyers)
9. See matched recyclers:
   - GreenTech: Score 94, ₹168/kg, Pickup, Authorized, 12km
   - Eco Recyclers: Score 82, ₹155/kg, Pickup, Authorized, 18km
10. Point out match score factors
11. See aggregation opportunity:
    - Your lot: 18 KG
    - Nearby: 24 + 31 + 19 = 74 KG combined → 92 KG total
    - Individual: ₹155/kg, Group: ₹168/kg
    - Additional value: ₹234
12. Select recycler or join aggregation

### Part 4: Transaction Flow (2 min)

1. Accept offer from GreenTech at ₹168/kg
2. Recycler confirms offer (simulate from recycler view or use seeded data)
3. Perform handover:
   - Enter reference number
   - Take handover photo
   - Enter final weight: 17.8 kg
   - Confirm handover
4. Record payment:
   - Amount: ₹2,990
   - Method: Cash
   - Status: Paid
5. Show payment confirmation

### Part 5: Material Passport (1 min)

1. Open the completed lot
2. Tap "View Passport"
3. Show the journey timeline:
   - Collected: Date, Location
   - Listed: Date
   - Offer Accepted: Date, GreenTech
   - Handover Verified: Date, Photo, Weight
   - Payment: ₹2,990, Cash
   - Received by Recycler: Date
   - Processing: (if recycler updated)
   - Awaiting recycler confirmation (for remaining steps)

### Part 6: Earnings (30 sec)

1. Go to "मेरी कमाई" (My Earnings)
2. Show total earnings
3. Show transaction history
4. Point out monthly breakdown

### Part 7: Safety (30 sec)

1. Open Safety Guide
2. Tap Battery Safety
3. Show the simple visual warnings
4. Tap the Listen button for voice guidance in Hindi

### Part 8: Offline Demo (2 min)

1. Show that the app is currently online (green indicator)
2. Turn off network/airplane mode
3. Show offline indicator
4. Create a new lot:
   - Select photo from gallery
   - Material: Cable
   - Weight: 12 kg
   - See cached price estimate
5. Lot is created with "Pending Sync" badge
6. Turn network back on
7. Watch the sync happen
8. Lot now shows "Synced" badge
9. Check backend: the lot appears in the API

### Part 9: Verification (30 sec)

1. Open verification screen
2. Enter a transaction reference (e.g., KAB-TXN-XXXXX)
3. Show the verified transaction with public-safe details

### Closing Points

- All data is clearly marked as demo data
- The classifier is a pluggable interface ready for real ML models
- Prices are from seeded observations, not claimed as live market data
- Recycler authorizations are demo references, not real certifications
- The system works offline for the critical collector workflow
- Hindi and Marathi are fully translated
- The architecture supports production scaling (swap SQLite for PostgreSQL, add real auth, plug in real classifier)
