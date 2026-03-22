import os
from fastapi import FastAPI

app = FastAPI(title="CMA Prep API", version="1.0.0")

@app.get("/")
def root():
    return {"status": "ok", "message": "CMA Prep API is live 🎓"}

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("app.main:app", host="0.0.0.0", port=port)