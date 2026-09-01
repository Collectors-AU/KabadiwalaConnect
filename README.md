# Kabadiwala Connect
PS26229
A digital infrastructure layer connecting informal e-waste collectors to the formal recycling ecosystem. The platform helps informal recyclers identify materials, discover fair prices, and sell to authorized recyclers with full digital traceability.

Built for SIH 2026.

## What this does

A collector photographs scrap material, the system identifies it using on-device inference, shows the fair local market value, connects them with authorized recyclers nearby, records the transaction, and creates a "material passport" tracking the journey from informal collection to formal recycling.

## Quick Start

### 1. Backend API (FastAPI)

```bash
cd apps/api
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp ../../.env.example .env
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API starts at `http://localhost:8000`. Demo data is seeded automatically on the first run.
API Docs (Swagger UI): `http://localhost:8000/docs`

### 2. Mobile App (Flutter)

You must have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install).

```bash
cd apps/mobile
flutter pub get
flutter run
```

If you wish to build an Android APK for distribution:
```bash
flutter build apk --release
```
The compiled APK will be output to `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Web Landing Page

The central marketing site and APK distribution hub is built with Vanilla HTML/CSS utilizing modern scroll-driven animations.

```bash
cd apps/web
python3 -m http.server 8080
```
Open your browser to `http://localhost:8080`.

## Project Structure

```
apps/
  api/          # FastAPI Backend Engine (Python, SQLite)
  mobile/       # Flutter Mobile Application (Dart)
  web/          # Marketing Landing Page & APK Distributor (HTML/CSS)
docs/           # Extensive Strategy & Technical Documentation
```

## Features

- **Fair Price Discovery**: Real-time material rates aggregated to prevent predatory pricing.
- **Material Classification**: Snap a photo to instantly classify scrap and estimate weight/value.
- **Smart Recycler Matching**: Rank authorized recyclers by materials accepted, rate, and distance.
- **Traceability Ledger**: Every lot gets a digital identity, recording GPS, timestamps, and verifiable handovers.
- **Offline & Low-Literacy Friendly**: Voice guidance, vernacular support (Hindi, Marathi), and core functions that work offline and sync later.
- **Call-to-Recycle (IVR concept)**: Enabling collectors without smartphones to participate via toll-free phone calls.

## Tech Stack

- **Mobile:** Flutter, Dart, Google Fonts, Image Picker
- **Backend:** FastAPI, Python 3.10+, SQLAlchemy, SQLite, Pydantic v2
- **Web:** Semantic HTML5, Vanilla CSS3 (Scroll-Timeline)

## Documentation

- [Strategic Analysis](docs/KABADIWALA_STRATEGIC_ANALYSIS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [MVP Scope](docs/MVP_SCOPE.md)
- [Demo Script](docs/DEMO_SCRIPT.md)
- [Data Dictionary](docs/DATA_DICTIONARY.md)
- [API Reference](docs/API.md)

## License

Private - SIH 2026 Submission.
