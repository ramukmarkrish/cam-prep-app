# Authenticate Docker with GCP
gcloud auth configure-docker us-central1-docker.pkg.dev

# Create a repository in Artifact Registry
gcloud artifacts repositories create cma-backend \
  --repository-format=docker \
  --location=us-central1 \
  --description="CMA App backend images"

# Build and tag for GCP
docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/cma-backend/api:v1 .

# Push the image
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/cma-backend/api:v1

# Deploy to Cloud Run
gcloud run deploy cma-api \
  --image=us-central1-docker.pkg.dev/YOUR_PROJECT_ID/cma-backend/api:v1 \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated \
  --service-account=cma-backend-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --port=8080
```

> 💡 `--allow-unauthenticated` is fine for now during development. We'll lock this down with Firebase Auth in Phase 5.

---

## Step 5 — Verify It's Live

Cloud Run will give you a URL like:
```
https://cma-api-xxxxxxxx-uc.a.run.app
