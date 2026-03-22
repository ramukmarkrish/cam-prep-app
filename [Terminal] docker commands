# Use official Python slim image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy and install dependencies first (Docker layer caching trick)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app/ ./app/

# Expose port 8080 (Cloud Run expects this)
EXPOSE 8080

# Start the server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]


#  --------------

cd backend

# Build the image
docker build -t cma-api .

# Run it locally
docker run -p 8080:8080 cma-api
