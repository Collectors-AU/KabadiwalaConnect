# Kabadiwala Connect
**Problem Statement:** PS26229 | **Hackathon:** Smart India Hackathon (SIH) 2026

Kabadiwala Connect is a scalable, offline-first digital infrastructure layer designed to seamlessly integrate India's informal e-waste collectors into the formal, statutory recycling ecosystem. It empowers informal waste pickers with transparent material valuation, on-device machine learning for scrap classification, and provides formal recyclers with cryptographically verifiable traceability for Extended Producer Responsibility (EPR) compliance.

## System Architecture

The ecosystem consists of three highly integrated components:

1. **Mobile Application (Flutter / Dart)**
   A ruggedized, offline-first mobile application optimized for the informal sector. It features multi-lingual text-to-speech accessibility, an embedded database (via Hive) for offline persistence, and quantized Edge ML models for real-time e-waste classification without internet dependency.

2. **Backend Engine (FastAPI / Python)**
   A high-performance backend enforcing CPCB guidelines. It manages data synchronization via a conflict-free resolution protocol, anomalous transaction detection using IsolationForest machine learning models, and real-time EPR credit valuation routing.

3. **Web Traceability Dashboard (HTML5 / Vanilla CSS3 / JS)**
   A zero-build-tool, lightweight command center for formal recyclers to monitor live intake, audit supply chains, and instantly export compliance logs formatted for CPCB statutory filings.

## Core Capabilities

- **On-Device Vision Classification:** Collectors photograph scrap to receive instant categorization and baseline pricing via a mobile-optimized neural network, bypassing predatory middleman pricing.
- **Dynamic Price Discovery:** Real-time calculation of informal baseline rates augmented with Producer-Funded Shared EPR bonuses.
- **Cryptographic Handovers:** Dual-tier transaction verification. Tier 1 utilizes dynamic QR codes containing SHA-256 hashed transaction payloads. Tier 2 provides an accessible 4-digit spoken PIN fallback for devices with damaged optical sensors.
- **Asynchronous Offline Sync:** Designed for zero-connectivity environments. Transactions are logged locally and pushed to the central server autonomously when network integrity is restored.
- **Anomaly Detection:** The backend actively screens incoming sync streams using predictive models to flag irregular transaction patterns (e.g., impossible volume velocities), ensuring ledger integrity.
- **Accessibility First:** Integrated voice guidance, native language localization, and high-contrast UI paradigms ensure the technology remains usable by illiterate or visually impaired stakeholders.

## Technical Stack

- **Client:** Flutter, Dart, Hive, TensorFlow Lite
- **Server:** Python 3.10+, FastAPI, SQLAlchemy, SQLite, Scikit-Learn
- **Web Interface:** Vanilla HTML5, CSS3, ES6 Modules

## Environment Setup & Deployment

### Backend Services
```bash
cd apps/mobile/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
The server initiates at `http://localhost:8000` with Swagger API documentation available at `/docs`.

### Mobile Application
Ensure the Flutter SDK is installed.
```bash
cd apps/mobile
flutter pub get
flutter run
```
To compile a release APK for Android distribution:
```bash
flutter build apk --release
```

### Traceability Dashboard
The web dashboard is served directly by the FastAPI backend under the static mount. Navigate to `http://localhost:8000/apps/mobile/backend/static/` to view live transaction telemetry and anomaly alerts.

## Project Documentation

Detailed system specifications and strategic analyses are located in the `docs/` directory:
- Strategic Analysis (`KABADIWALA_STRATEGIC_ANALYSIS.md`)
- Architecture Design (`ARCHITECTURE.md`)
- MVP Feature Scope (`MVP_SCOPE.md`)
- Application Data Dictionary (`DATA_DICTIONARY.md`)
- API Specification (`API.md`)

## License

Private Repository - Exclusive submission for Smart India Hackathon 2026.
