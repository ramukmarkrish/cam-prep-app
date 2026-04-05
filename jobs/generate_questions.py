import requests
import time
import os
import psycopg2
import logging
logging.basicConfig(level=logging.INFO)

API_BASE_URL = "https://cma-api-923923178690.us-central1.run.app"

def main():
    logging.info("🚀 Starting question generation job")

    # Health check
    response = requests.get(f"{API_BASE_URL}/health")
    health = response.json()
    logging.info(f"✅ API Health: {health}")

    if health.get("database") != "connected":
        logging.error("❌ Database not connected — aborting")
        return

    # Get all topics
    topics = requests.get(f"{API_BASE_URL}/topics").json()
    logging.info(f"📚 Found {len(topics)} topics")

    success = 0
    failed = 0

    for topic in topics:
        for difficulty in ["medium", "hard"]:
            try:
                logging.info(f"🤖 Generating {difficulty} for {topic['name']}...")
                response = requests.get(
                    f"{API_BASE_URL}/topics/{topic['id']}/questions",
                    params={
                        "difficulty": difficulty,
                        "user_id": "airflow_scheduler"
                    },
                    timeout=90
                )
                if response.status_code == 200:
                    questions = response.json()
                    logging.info(f"✅ {len(questions)} questions cached")
                    success += 1
                else:
                    logging.error(f"❌ Failed: {response.status_code}")
                    failed += 1
            except Exception as e:
                logging.error(f"❌ Error: {str(e)}")
                failed += 1

            time.sleep(3)  # avoid rate limiting

    logging.info(f"🎉 Done! Success: {success} Failed: {failed}")

if __name__ == "__main__":
    main()
EOF