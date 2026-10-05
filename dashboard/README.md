# PoultryGuard — Surveillance & Disease Control Admin Dashboard

Enterprise-grade surveillance, outbreak containment, and AI-powered disease diagnostics dashboard for the **PoultryGuard** poultry biosecurity platform.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [System Architecture Flow](#system-architecture-flow)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
  - [Backend Environment Variables](#backend-environment-variables)
  - [Frontend Environment Variables](#frontend-environment-variables)
- [Quick Start Guide](#quick-start-guide)
  - [1. Backend Setup (FastAPI + PostgreSQL)](#1-backend-setup-fastapi--postgresql)
  - [2. Frontend Setup (React + Vite)](#2-frontend-setup-react--vite)
- [Features & Dashboard Modules](#features--dashboard-modules)
- [Security & Secrets Policy](#security--secrets-policy)
- [Testing & Quality Assurance](#testing--quality-assurance)

---

## 🌟 Overview

The **PoultryGuard Dashboard** provides government officials, veterinarians, and poultry farm administrators with real-time operational visibility into commercial poultry operations across Pakistan. It combines IoT telemetry (ESP32 sensor feeds), computer vision AI (multimodal Gemini vision analysis for disease detection), geospatial outbreak heatmaps, and role-based farm management.

---

## 🏗 Architecture & Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Frontend** | React 19, Vite, Tailwind CSS, Leaflet & CARTO Basemaps, Recharts, Lucide Icons, TanStack Query |
| **Backend** | Python 3.12+, FastAPI, SQLAlchemy ORM, Alembic migrations, SlowAPI rate-limiting, GZip compression |
| **Database** | PostgreSQL (System of Record for farms, users, flocks, outbreak alerts, sensor logs, diagnoses) |
| **Authentication** | Firebase Authentication (JWT verification via `firebase-admin` & role guards) |
| **IoT Telemetry** | Firebase Realtime Database (RTDB) sync worker & HMAC device authentication |
| **Vision AI** | Google Gemini Multimodal Vision API (avian pathology & symptom diagnostics) |

---

## 🔄 System Architecture Flow

```
[ ESP32 IoT Nodes ] ──(HMAC / Pre-Shared Key)──> [ FastAPI IoT Ingestion ]
                                                         │
                                                  (RTDB Realtime Stream)
                                                         │
                                                         ▼
[ Mobile App (Farmers/Vets) ] ──(Firebase Auth)──> [ Firebase Services ]
                                                         │ (ID Token JWT)
                                                         ▼
[ Web Admin Dashboard ] ───────(REST / Bearer)─────> [ FastAPI Backend (BFF) ]
                                                         │
                                                         ▼
                                                [ PostgreSQL Database ]
                                                (System of Record)
```

---

## 📁 Directory Structure

```
dashboard/
├── README.md                                 # Module documentation
├── database.rules.json                       # Firebase RTDB security rules
├── firestore.rules                           # Cloud Firestore security rules
├── storage.rules                             # Firebase Cloud Storage security rules
├── backend/
│   ├── .env.example                          # Backend configuration template
│   ├── requirements.txt                      # Python dependencies
│   ├── main.py                               # FastAPI application entrypoint
│   ├── alembic/                              # Database migration scripts
│   ├── auth/                                 # Firebase JWT verification & IoT auth
│   │   ├── firebase_verify.py                # Firebase Admin token dependency
│   │   ├── role_guard.py                     # Role-based access control (RBAC)
│   │   ├── iot_auth.py                       # ESP32 hardware authentication
│   │   └── security.py                       # Security headers & rate limiting
│   ├── db/                                   # PostgreSQL connection session
│   ├── models/                               # SQLAlchemy database models
│   │   ├── user.py                           # User profiles & roles
│   │   ├── farm.py                           # Farms & geographic coordinates
│   │   ├── flock.py                          # Flock batches & vaccination logs
│   │   ├── sensor_reading.py                 # Time-series environmental data
│   │   ├── outbreak_alert.py                 # Quarantine & disease alerts
│   │   └── diagnosis.py                      # AI & clinical diagnostic records
│   ├── routers/                              # API route handlers
│   │   ├── admin/                            # Admin endpoints (BFF, farms, analytics, etc.)
│   │   └── shared/                           # Shared user endpoints (/me)
│   ├── schemas/                              # Pydantic validation & error models
│   ├── services/                             # Background sync & caching
│   ├── scripts/                              # Demo seed scripts
│   └── tests/                                # Pytest automated test suite
└── frontend/
    └── poultryguard-dashboard/
        ├── .env.example                      # Frontend environment template
        ├── index.html                        # Application entry HTML
        ├── package.json                      # Dependencies and scripts
        ├── vite.config.js                    # Vite bundler configuration
        └── src/
            ├── api/                          # Axios API clients and endpoints
            ├── auth/                         # Firebase authentication & AuthContext
            ├── components/                   # Reusable UI components & layouts
            ├── config/                       # Map & tile configurations
            ├── hooks/                        # Custom React hooks (realtime sensors, toast)
            ├── pages/                        # Dashboard views and analytics screens
            └── services/                     # Gemini AI Vision service
```

---

## ⚙️ Prerequisites

- **Node.js**: v18.0.0 or higher
- **Python**: v3.11 or higher
- **PostgreSQL**: v14 or higher (or SQLite for dev testing)
- **Firebase Project**: Firebase Auth + Realtime Database configured

---

## 🔐 Environment Configuration

> **CRITICAL SECURITY NOTICE**: Never commit `.env` files, credentials, or private keys to source control. Both `.gitignore` files are pre-configured to exclude all `.env` files, SQLite databases, and service account keys.

### Backend Environment Variables

Create `dashboard/backend/.env` from `dashboard/backend/.env.example`:

```bash
cp backend/.env.example backend/.env
```

| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:password@localhost:5432/poultryguard` |
| `FIREBASE_PROJECT_ID` | Firebase project identifier | `poultryguard-d2d7f` |
| `FIREBASE_DATABASE_URL` | Firebase Realtime Database URL | `https://<project-id>-default-rtdb.firebaseio.com` |
| `FIREBASE_CREDENTIALS_PATH` | (Optional) Path to Admin SDK JSON | `path/to/serviceAccountKey.json` |
| `GEMINI_API_KEY` | Google Gemini AI Vision API key | `AIzaSy...` |
| `IOT_DEVICE_SECRET` | Pre-shared key for ESP32 nodes | `pg_iot_sec_...` |
| `CORS_ALLOWED_ORIGINS` | Comma-separated allowed origins | `http://localhost:5173,http://127.0.0.1:5173` |
| `ENVIRONMENT` | Runtime environment | `development` or `production` |

### Frontend Environment Variables

Create `dashboard/frontend/poultryguard-dashboard/.env` from `.env.example`:

```bash
cp frontend/poultryguard-dashboard/.env.example frontend/poultryguard-dashboard/.env
```

| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `VITE_API_URL` | Backend FastAPI server URL | `http://127.0.0.1:8000` |
| `VITE_FIREBASE_API_KEY` | Firebase Web API key | `AIzaSy...` |
| `VITE_FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain | `poultryguard-d2d7f.firebaseapp.com` |
| `VITE_FIREBASE_PROJECT_ID` | Firebase Project ID | `poultryguard-d2d7f` |
| `VITE_FIREBASE_STORAGE_BUCKET`| Firebase Cloud Storage bucket | `poultryguard-d2d7f.firebasestorage.app` |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Cloud Messaging Sender ID | `591182538656` |
| `VITE_FIREBASE_APP_ID` | Firebase Web App ID | `1:591182538656:web:...` |
| `VITE_GEMINI_API_KEY` | (Optional) Gemini Vision API key | `AIzaSy...` |
| `VITE_CARTO_API_KEY` | (Optional) CARTO Basemaps Key | `cb1_...` |

---

## 🚀 Quick Start Guide

### 1. Backend Setup (FastAPI + PostgreSQL)

```bash
cd dashboard/backend

# Create virtual environment
python -m venv .venv

# Activate virtual environment
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations (or seed database)
python scripts/seed_comprehensive_demo.py

# Start development server
uvicorn main:app --reload --port 8000
```
Backend API will be accessible at: `http://127.0.0.1:8000` (Swagger docs at `/docs`).

### 2. Frontend Setup (React + Vite)

```bash
cd dashboard/frontend/poultryguard-dashboard

# Install npm dependencies
npm install

# Start development server
npm run dev
```
Dashboard web UI will be accessible at: `http://localhost:5173`.

---

## 📊 Features & Dashboard Modules

1. **Dashboard Overview (BFF Pattern)**: Single-roundtrip aggregated KPI metrics, farm status counters, active alerts, and real-time live activity logs.
2. **Surveillance Map & Heatmap**: Interactive Leaflet maps rendering nationwide poultry farms across Pakistan with risk severity indicators.
3. **Farm & Flock Management**: Multi-shed batch tracking, placement dates, bird counts, and vaccination schedule logs.
4. **IoT Environmental Monitoring**: Real-time telemetry monitoring temperature, humidity, ammonia ($NH_3$), and air quality thresholds.
5. **AI Disease Detection (Gemini Multimodal)**: Pathology image diagnosis for Newcastle Disease (ND), Avian Influenza (AI), Infectious Bronchitis (IB), and Coccidiosis with confidence scores and biosafety recommendations.
6. **Outbreak Containment & Verification**: Veterinary verification queues for laboratory diagnoses and quarantine perimeter enforcement.
7. **User & Access Management**: Role-based access control governing Admins, Field Veterinarians, and Farmers.

---

## 🛡️ Security & Secrets Policy

- **No Secrets in Code**: All API keys, database credentials, and signing secrets are strictly loaded through environment variables.
- **Defense in Depth**: Integrated HTTP security headers (`HSTS`, `CSP`, `X-Frame-Options`, `X-Content-Type-Options`).
- **Rate Limiting**: Sliding-window rate limiters prevent credential brute-forcing and denial-of-service vectors.
- **Git Ignore Safeguards**: `.gitignore` rules prevent accidental commits of `.env`, `*.key`, `*.pem`, `*.db`, or service account credentials.

---

## 🧪 Testing & Quality Assurance

Run the automated backend test suite:
```bash
cd dashboard/backend
pytest tests/ -v
```

Run frontend build verification:
```bash
cd dashboard/frontend/poultryguard-dashboard
npm run build
```
