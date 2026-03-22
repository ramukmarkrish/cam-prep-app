# CMA Success App

A mobile app to help prepare for the CMA (Certified Management Accountant) exam.
Built with FastAPI, SwiftUI, Google Cloud, and Gemini AI.

## Architecture
```
iOS App (SwiftUI)
      ↕ HTTPS
Cloud Run (FastAPI)
      ↕
Cloud SQL (PostgreSQL) ← Airflow DAGs (coming)
      ↓
BigQuery (analytics - coming)
```

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Swift + SwiftUI |
| Backend | Python + FastAPI |
| Database | Cloud SQL (PostgreSQL 15) |
| AI | Google Gemini 2.5 Flash |
| Hosting | Google Cloud Run |
| Container Registry | Google Artifact Registry |
| Secrets | Google Secret Manager |
| Version Control | GitHub |

## Project Structure
```
cma-prep-app/
├── backend/                    ← FastAPI backend
│   ├── app/
│   │   ├── main.py            ← API endpoints
│   │   ├── models.py          ← SQLAlchemy models
│   │   ├── database.py        ← DB connection
│   │   └── gemini.py          ← Gemini AI integration
│   ├── Dockerfile             ← Container definition
│   └── requirements.txt       ← Python dependencies
├── ios/
│   └── CMASuccess/            ← SwiftUI iOS app
│       └── CMASuccess/
│           ├── Models/
│           │   └── APIModels.swift
│           ├── Services/
│           │   └── APIService.swift
│           ├── Views/
│           │   ├── HomeView.swift
│           │   ├── TopicListView.swift
│           │   ├── QuizView.swift
│           │   ├── MyProgressView.swift
│           │   └── ResultView.swift
│           └── ContentView.swift
├── infra/
│   ├── schema.sql             ← Database schema
│   └── scripts/               ← GCP setup scripts
└── README.md
```

## GCP Setup

### Project Details
- Project ID: `cma-prep-app`
- Region: `us-central1`
- Cloud Run URL: `https://cma-api-923923178690.us-central1.run.app`

### Services Enabled
- Cloud Run
- Cloud SQL (PostgreSQL 15)
- Vertex AI / Gemini
- Artifact Registry
- Secret Manager
- Cloud Build

### Service Account
- Name: `cma-backend-sa@cma-prep-app.iam.gserviceaccount.com`
- Roles: `cloudsql.client`, `aiplatform.user`, `secretmanager.secretAccessor`

### Secrets in Secret Manager
- `cma-db-password` — Full PostgreSQL connection string
- `cma-gemini-key` — Google Gemini API key

## Database

### Instance
- Name: `cma-postgres`
- Version: PostgreSQL 15
- Tier: `db-f1-micro`
- Region: `us-central1`

### Tables
| Table | Purpose | Populated By |
|---|---|---|
| `topics` | CMA subject areas | Manual seed |
| `questions` | AI generated questions | Gemini |
| `answers` | Question options | Gemini |
| `user_progress` | Every answer attempt | iOS app |
| `user_streaks` | Gamification | Airflow (coming) |
| `user_topic_stats` | Per topic performance | iOS app |
| `study_sessions` | Daily sessions | iOS app |
| `gemini_job_log` | AI generation audit | Airflow (coming) |

### Connect to Database Locally
```bash
# Start Cloud SQL proxy
./cloud-sql-proxy cma-prep-app:us-central1:cma-postgres --port 5432 &

# Connect
gcloud sql connect cma-postgres --user=cma-user --database=cmadb
```

## Local Development

### Prerequisites
- Python 3.11
- Docker Desktop
- Google Cloud SDK
- Xcode (for iOS)
- cloud-sql-proxy binary in project root

### Backend Setup
```bash
cd backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cat > .env << 'EOF'
DATABASE_URL=postgresql://cma-user:YOUR_PASSWORD@localhost:5432/cmadb
GCP_PROJECT_ID=cma-prep-app
GEMINI_API_KEY=your_gemini_api_key
EOF

# Start Cloud SQL proxy (separate terminal)
./cloud-sql-proxy cma-prep-app:us-central1:cma-postgres --port 5432 &

# Run API
uvicorn app.main:app --reload --port 8080
```

API docs available at: `http://localhost:8080/docs`

### iOS Setup
1. Open `ios/CMASuccess/CMASuccess.xcodeproj` in Xcode
2. Select iPhone simulator
3. Press `Cmd + R` to run

## Deployment

### Deploy Backend to Cloud Run
```bash
cd backend

# Build Docker image (AMD64 for Cloud Run)
docker buildx build \
  --platform linux/amd64 \
  -t us-central1-docker.pkg.dev/cma-prep-app/cma-backend/api:vX \
  --push \
  .

# Deploy to Cloud Run
gcloud run deploy cma-api \
  --image=us-central1-docker.pkg.dev/cma-prep-app/cma-backend/api:vX \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated \
  --service-account=cma-backend-sa@cma-prep-app.iam.gserviceaccount.com \
  --port=8080 \
  --set-env-vars="GCP_PROJECT_ID=cma-prep-app" \
  --set-secrets="DATABASE_URL=cma-db-password:latest,GEMINI_API_KEY=cma-gemini-key:latest" \
  --add-cloudsql-instances=cma-prep-app:us-central1:cma-postgres
```

> Replace `vX` with the next version number (v7, v8, etc.)

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Health check |
| GET | `/topics` | Get all CMA topics |
| GET | `/topics/{id}/questions` | Get questions (Gemini generates if needed) |
| POST | `/submit` | Submit answer + get explanation |
| GET | `/progress/{user_id}` | Get user progress summary |

## App Flow
```
Home Screen
    ↓ tap "Start Studying"
Topic List (Part 1 + Part 2)
    ↓ tap a topic
Loading (Gemini generates questions)
    ↓
Question Screen
    ↓ tap answer
Result Screen (correct/wrong + AI explanation)
    ↓ tap "Next Question"
Next Question...
    ↓ after all questions
Summary Screen (score + accuracy)
```

## Adaptive Learning

- Starts at **Medium** difficulty (she has theoretical knowledge)
- After 15 questions per topic:
  - Accuracy ≥ 70% → upgrades to **Hard**
  - Accuracy < 50% → downgrades to **Medium**
- Questions cached in DB (reused max 3 times)
- Fresh questions generated by Gemini nightly (Airflow - coming)

## Coming Soon

- [ ] Airflow DAGs for nightly question generation
- [ ] BigQuery analytics dashboard
- [ ] Push notifications for daily reminders
- [ ] TestFlight deployment to real iPhone
- [ ] Firebase Auth for secure login
- [ ] Timer per question (exam simulation)

## Common Issues & Fixes

### Docker not found
```bash
open /Applications/Docker.app
# Wait for whale icon to be steady in menu bar
```

### Cloud SQL proxy connection refused
```bash
# Check if Cloud SQL instance is running
gcloud sql instances describe cma-postgres --format="value(state)"
# If STOPPED:
gcloud sql instances patch cma-postgres --activation-policy=ALWAYS
```

### Git push rejected
```bash
git pull origin main --no-rebase
git push origin main
```

### Gemini quota exceeded
- Check billing at console.cloud.google.com
- Verify API key at aistudio.google.com

## Cost Estimate
| Service | Monthly Cost |
|---|---|
| Cloud SQL (scheduled) | ~$5-8 |
| Cloud Run | ~$0-2 |
| Gemini API | ~$1-3 |
| **Total** | **~$7-11** |

> Stop Cloud SQL when not in use:
> `gcloud sql instances patch cma-postgres --activation-policy=NEVER`


#Save and Commit
git add .
git commit -m "docs: add comprehensive README"
git push origin main


# Save exact versions of everything
cat > cma-prep-app/infra/environment.md << 'EOF'
# Environment Details

## Mac
- macOS: 15.7.4
- Xcode: latest
- Python: 3.11
- Docker Desktop: latest

## GCP
- Project: cma-prep-app
- Region: us-central1
- Cloud SQL: cma-postgres (PostgreSQL 15)
- Cloud Run: cma-api
- Artifact Registry: cma-backend

## Key Versions
- FastAPI: 0.111.0
- SQLAlchemy: 2.0.30
- google-genai: 1.0.0
- Swift: 5.x
- SwiftUI: iOS 17+
EOF

git add .
git commit -m "docs: add environment details"
git push origin main
```

---

## Two Years From Now — What to Do

If you open this project in 2 years:
```
1. git clone https://github.com/ramukmarkrish/cam-prep-app
2. Read README.md
3. Install prerequisites (Python 3.11, Docker, Xcode, gcloud)
4. Run gcloud auth login
5. Start Cloud SQL proxy
6. Create .env with secrets from Secret Manager
7. Run uvicorn — you're back!