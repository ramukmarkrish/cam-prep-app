# 1. Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Google Cloud SDK
brew install --cask google-cloud-sdk
gcloud auth login
gcloud config set project cma-prep-app

# 3. Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# 4. Python 3.11+
brew install python@3.11

# 5. VS Code
brew install --cask visual-studio-code


mkdir cma-prep-app && cd cma-prep-app

mkdir -p backend/app
mkdir -p ios  # SwiftUI project will live here later
mkdir -p infra  # Cloud SQL setup scripts

touch backend/app/main.py
touch backend/Dockerfile
touch backend/requirements.txt
touch .gitignore
```

Your final structure will look like:
```
cma-prep-app/
├── backend/          ← FastAPI + Cloud Run
│   ├── app/
│   │   └── main.py
│   ├── Dockerfile
│   └── requirements.txt
├── ios/              ← SwiftUI app (Xcode project)
└── infra/            ← SQL schemas, GCP setup scripts
