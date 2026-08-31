# Kabadiwala Connect

An e-waste collector management platform that helps informal recyclers identify, price, and sell collected materials to authorized recyclers with full traceability.

Built for SIH 2026.

## What this does

A collector photographs scrap material, the system identifies it, shows fair market value, connects with authorized recyclers, records the transaction, and creates a material passport tracking the journey from collection to recycling.

## Quick Start

### Backend API

```bash
cd apps/api
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp ../../.env.example .env
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API starts at http://localhost:8000. Demo data is seeded automatically on first run.

API docs: http://localhost:8000/docs

### Mobile App

```bash
cd apps/mobile
npm install
npx expo start
```

Scan the QR code with Expo Go, or press `a` for Android emulator.

For Android emulator, the API URL is automatically set to `http://10.0.2.2:8000`.

### Demo Credentials

The app uses demo login. No passwords needed.

| Role | Name | Language |
|------|------|----------|
| Collector | Ramesh Kumar | Hindi |
| Collector | Priya Sharma | Hindi |
| Collector | Ganesh Patil | Marathi |
| Recycler | GreenTech E-Waste Solutions | English |
| Admin | Admin User | English |

## Project Structure

```
apps/
  api/          # FastAPI backend
  mobile/       # React Native / Expo mobile app
docs/           # Documentation
```

## Features

- Material classification (demo classifier, pluggable for real models)
- Price intelligence with trend analysis
- Recycler matching and scoring
- Smart aggregation for better group pricing
- Offline-first: create lots without internet, sync when connected
- Hindi and Marathi language support
- Voice guidance for safety and prices
- Material passport with full traceability
- Transaction anomaly detection
- Recycler demand broadcasting
- Payment recording (Cash, UPI, Bank Transfer)
- Admin dashboard with metrics
- Recycler dashboard for incoming lots

## Tech Stack

- **Mobile:** React Native, Expo, TypeScript, SQLite
- **Backend:** FastAPI, Python, SQLAlchemy, SQLite
- **AI:** Pluggable classifier interface (demo classifier included)

## Documentation

- [Architecture](ARCHITECTURE.md)
- [MVP Scope](MVP_SCOPE.md)
- [Demo Script](DEMO_SCRIPT.md)
- [Data Dictionary](DATA_DICTIONARY.md)
- [API Reference](API.md)
- [Offline Sync](OFFLINE_SYNC.md)
- [AI Approach](AI_APPROACH.md)

## License

Private - SIH 2026 submission.
