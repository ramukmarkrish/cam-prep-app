FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

EXPOSE 8080

# Use shell form so $PORT env variable is evaluated at runtime
CMD exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}