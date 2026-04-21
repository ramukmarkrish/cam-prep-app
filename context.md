# CMA Success App — Session Context

## Current Status
- Backend: FastAPI on Cloud Run ✅
- Database: Cloud SQL PostgreSQL ✅  
- iOS App: SwiftUI on iPhone 14 Pro Max ✅
- CI/CD: GitHub Actions ✅
- Question Generation: Gemini 2.5 Flash ✅

## GCP Details
- Project: cma-prep-app
- Cloud Run URL: https://cma-api-923923178690.us-central1.run.app
- Cloud SQL: cma-postgres (PostgreSQL 15)
- Region: us-central1
- Service Account: cma-backend-sa@cma-prep-app.iam.gserviceaccount.com

## GitHub
- Repo: github.com/ramukmarkrish/cam-prep-app

## Tech Stack
- Backend: Python 3.11, FastAPI, SQLAlchemy, google-genai==1.0.0
- iOS: SwiftUI, Swift
- AI: Gemini 2.5 Flash via google-genai SDK
- DB: PostgreSQL 15, psycopg2

## Pending Work
- [ ] Fix quiz loading on iPhone (questions not showing after spinner)
- [ ] Fill remaining DB questions (Part 2 topics missing)
- [ ] Cloud Run Job for nightly question generation
- [ ] Question timer
- [ ] Firebase Auth

## Known Issues
- Cloud SQL must be started manually each session
- Gemini free tier hits limits quickly — billing enabled
- iOS loading text invisible (white on white background)

## File Structure
backend/
  app/
    main.py      ← API endpoints
    models.py    ← SQLAlchemy models  
    database.py  ← DB connection
    gemini.py    ← Gemini integration
  Dockerfile
  requirements.txt
ios/CMASuccess/CMASuccess/
  Models/APIModels.swift
  Services/APIService.swift
  Views/HomeView.swift
  Views/TopicListView.swift
  Views/QuizView.swift
  Views/MyProgressView.swift
  ContentView.swift
jobs/
  generate_questions.py
  Dockerfile
airflow/dags/
  generate_questions.py
.github/workflows/
  deploy.yml