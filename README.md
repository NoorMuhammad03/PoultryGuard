# PoultryGuard ? Smart Poultry Surveillance & Biosecurity Platform

An intelligent IoT-enabled poultry biosafety, disease surveillance, and farm management platform integrating edge sensor nodes, mobile applications for farmers & veterinarians, and an enterprise web surveillance dashboard.

---

## ?? Platform Architecture & Modules

The PoultryGuard codebase is organized into modular subsystems:

| Directory | Module Description | Stack |
| :--- | :--- | :--- |
| [dashboard/](./dashboard) | Web Surveillance & Disease Control Admin Dashboard | React 19, Vite, FastAPI, PostgreSQL, Firebase |
| [mobile/](./mobile) | Farmer & Field Veterinarian Mobile Application | Flutter / Dart |
| [ackend/](./backend) | Core Mobile Backend & Authentication APIs | FastAPI, Python |
| [hardware/](./hardware) | ESP32 IoT Environmental Sensor Firmware | C++ / Arduino |
| [docs/](./docs) | Platform Specifications & Documentation | Markdown |

---

## ?? Dashboard Module Quick Start

The surveillance dashboard provides disease outbreak tracking, real-time sensor monitoring, AI multimodal vision diagnosis, and veterinary verification.

To run the dashboard locally:

### 1. Backend (FastAPI + PostgreSQL)
`ash
cd dashboard/backend
cp .env.example .env
python -m venv .venv
# Activate .venv
pip install -r requirements.txt
python scripts/seed_comprehensive_demo.py
uvicorn main:app --reload --port 8000
`

### 2. Frontend (React 19 + Vite)
`ash
cd dashboard/frontend/poultryguard-dashboard
cp .env.example .env
npm install
npm run dev
`

For detailed documentation, architecture diagrams, and environment configuration guides, see the [Dashboard Documentation](./dashboard/README.md).

---

## ?? Security & Secrets Policy

No sensitive credentials, API keys, private tokens, or service account files may be committed to this repository. All secrets must reside exclusively in local .env files which are excluded from source control.
