# PoultryGuard — Local PC Installation & Execution Guide

This step-by-step guide walks you through setting up and running both the **FastAPI Backend** and the **React Vite Frontend** on a local Windows (or macOS/Linux) computer.

---

## 1. Prerequisites

Before starting, ensure the following software is installed on your PC:
* **Python 3.11+**: [python.org](https://www.python.org/downloads/) *(Ensure "Add Python to PATH" is checked during installation)*.
* **Node.js 18+ & npm**: [nodejs.org](https://nodejs.org/) *(LTS version recommended)*.
* **Git**: [git-scm.com](https://git-scm.com/).
* **Terminal**: Windows PowerShell, Command Prompt, or Git Bash.

---

## 2. Directory Layout

Open your terminal and navigate to the project directory:
```powershell
cd E:\Poultry-Guard\Dashboard
```

The workspace contains two primary application subdirectories:
* `backend/` — Python FastAPI REST API with SQLite/PostgreSQL persistence.
* `frontend/poultryguard-dashboard/` — React 19 Single Page Application built with Vite.

---

## 3. Step 1: Backend Setup & Execution

### 3.1. Open a Terminal for Backend
Open a terminal window and enter the `backend` folder:
```powershell
cd E:\Poultry-Guard\Dashboard\backend
```

### 3.2. Create and Activate Python Virtual Environment
* **On Windows (PowerShell):**
  ```powershell
  python -m venv .venv
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .venv\Scripts\Activate.ps1
  ```
* **On Windows (Command Prompt):**
  ```cmd
  python -m venv .venv
  .venv\Scripts\activate.bat
  ```
* **On macOS/Linux:**
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  ```

*(Your terminal prompt should now display `(.venv)`).*

### 3.3. Install Python Dependencies
```powershell
pip install -r requirements.txt
```

### 3.4. Configure Environment Variables (`backend/.env`)
Ensure a `.env` file exists in the `backend/` folder. If it does not exist, create it:
```ini
DATABASE_URL=sqlite:///./poultryguard.db
USE_SQLITE=True
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_ADMIN_CREDENTIALS=
GEMINI_API_KEY=your_gemini_api_key_here
```

> **Note:** `USE_SQLITE=True` enables the zero-configuration SQLite database (`poultryguard.db`), eliminating the need to install or run a separate PostgreSQL server locally.

### 3.5. Initialize & Seed the Database
Run the seed script to create all database tables and populate the default administrator account, demo farms, flocks, and 7-day sensor histories:
```powershell
python scripts/seed_demo.py
```
*Expected Output:*
```
[INFO] Database tables created successfully.
[INFO] Seeded default administrator: admin@poultryguard.pk
[INFO] Seeded 3 demonstration poultry farms with historical telemetry.
```

### 3.6. Start the FastAPI Server
Run Uvicorn with auto-reloading enabled:
```powershell
uvicorn main:app --reload --port 8000
```
* The backend is now live at: `http://127.0.0.1:8000`
* Interactive API Documentation (Swagger): `http://127.0.0.1:8000/docs`
* Health check: `http://127.0.0.1:8000/health`

---

## 4. Step 2: Frontend Setup & Execution

### 4.1. Open a Second Terminal for Frontend
Leave the backend terminal running. Open a **new terminal window** and navigate to the frontend directory:
```powershell
cd E:\Poultry-Guard\Dashboard\frontend\poultryguard-dashboard
```

### 4.2. Install Node Dependencies
```powershell
npm install
```

### 4.3. Configure Environment Variables (`frontend/.../.env`)
Ensure `.env` exists in `frontend/poultryguard-dashboard/` with the following configuration:
```ini
VITE_API_URL=http://127.0.0.1:8000
VITE_FIREBASE_API_KEY=your_firebase_api_key_here
VITE_FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project_id.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
VITE_FIREBASE_MEASUREMENT_ID=your_measurement_id
VITE_GEMINI_API_KEY=your_gemini_api_key_here
```

### 4.4. Start the Vite Development Server
```powershell
npm run dev
```
*Expected Output:*
```
  VITE v8.2.1  ready in 240 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

---

## 5. Step 3: Accessing the Dashboard & Default Credentials

1. Open your web browser and navigate to:
   ```
   http://localhost:5173
   ```
2. You will be redirected to the **Login** screen (`/login`).
3. Sign in using your administrator account:
   * **Email:** `admin@poultryguard.pk` (or registered email)
   * **Password:** `your_password`
4. Click **"Log in"**. You will enter the **PoultryGuard Executive Overview** (`/overview`).

---

## 6. Verifying Key Capabilities

### 6.1. AI Multimodal Pathogen Diagnosis (`/ai-detection`)
1. In the sidebar, click **"AI Diagnosis"**.
2. Select one of the pre-loaded high-confidence field presets (e.g., *Suspected Coccidiosis* or *Newcastle Disease*), or upload your own poultry dropping photograph.
3. Click **"Analyze image with Gemini AI"**.
4. Observe the live pulsing laser scanning overlay (`.laser-scanner`) and real-time step progress indicator.
5. Review the structured diagnostic output:
   * Model Confidence Score (%)
   * Clinical pathology explanation ("What this may indicate")
   * Interactive operator checklist with toggleable checkmarks
   * Expandable differential diagnosis accordions
   * ISO/IEC 23894 certified medical disclaimer banner in Alert Red (`#D9534F`)

### 6.2. Smart Sensor & Edge Control Insights (`/sensors`)
1. In the sidebar, click **"Sensor Logs"**.
2. Locate the **"Smart Sensor & Edge Control Insights"** card.
3. Click **"Re-Analyze Climate Payload"** to trigger a live analysis of current temperature, humidity, ammonia, and gas metrics.
4. Review Gemini's operational directives for automated exhaust ventilation, evaporative cooling pads, and the interactive climate checklist.
5. Inspect the 7-day trend chart with temperature (30°C/32°C), humidity (70%/80%), and ammonia (20/25 ppm) reference lines.

### 6.3. Geospatial Surveillance (`/farms` & `/outbreaks`)
1. Click **"Farms Map"** to interact with Leaflet GIS markers across Punjab and Sindh zones.
2. Click **"Outbreaks"** to view radial infection quarantine buffers (3km/5km/10km).

---

## 7. Troubleshooting & FAQ

### Issue: "Activate.ps1 cannot be loaded because running scripts is disabled on this system"
* **Solution:** PowerShell blocks unsigned script execution by default. Run:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .venv\Scripts\Activate.ps1
  ```

### Issue: Port 8000 or Port 5173 is already in use
* **Solution (Backend):** Specify a different port for Uvicorn:
  ```powershell
  uvicorn main:app --reload --port 8001
  ```
  *(Remember to update `VITE_API_URL=http://127.0.0.1:8001` in `frontend/poultryguard-dashboard/.env`)*.
* **Solution (Frontend):** Vite automatically increments to port `5174` if `5173` is busy.

### Issue: CORS 405 Method Not Allowed on `/api/v1/me`
* **Solution:** Ensure the FastAPI application in `backend/main.py` includes `CORSMiddleware` with `allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"]`, `allow_credentials=True`, `allow_methods=["*"]`, and `allow_headers=["*"]`. (Already configured in current code).

### Issue: Firebase "auth/invalid-credential"
* **Solution:** Ensure the admin user exists in both Firebase Authentication and SQLite. If you wish to create a fresh user, toggle to **"Create one"** on the login page to register directly through the client interface.
