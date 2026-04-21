import requests
import time
import os
import psycopg2
import logging
logging.basicConfig(level=logging.INFO)

API_BASE_URL = "https://cma-api-923923178690.us-central1.run.app"
TARGET_QUESTIONS = 200  # target per topic per difficulty
BATCH_SIZE = 10         # Gemini generates 10 at a time

def get_question_count(topic_id, difficulty):
    """Check existing question count from DB via API"""
    response = requests.get(
        f"{API_BASE_URL}/topics/{topic_id}/questions",
        params={"difficulty": difficulty, "limit": 1}
    )
    return len(response.json()) if response.status_code == 200 else 0

def generate_batch(topic_id, difficulty):
    """Generate one batch of questions"""
    response = requests.get(
        f"{API_BASE_URL}/topics/{topic_id}/questions",
        params={
            "difficulty": difficulty,
            "user_id": "bulk_generator",
            "limit": BATCH_SIZE
        },
        timeout=90
    )
    return response.status_code == 200

def main():
    logging.info("🚀 Starting bulk question generation")

    # Health check
    health = requests.get(f"{API_BASE_URL}/health").json()
    if health.get("database") != "connected":
        logging.error("❌ DB not connected — aborting")
        return

    topics = requests.get(f"{API_BASE_URL}/topics").json()
    logging.info(f"📚 Found {len(topics)} topics")

    for topic in topics:
        for difficulty in ["medium", "hard"]:
            logging.info(f"\n📖 {topic['name']} — {difficulty}")
            
            batches_needed = TARGET_QUESTIONS // BATCH_SIZE  # 20 batches
            success = 0

            for batch in range(batches_needed):
                logging.info(f"  Batch {batch + 1}/{batches_needed}...")
                if generate_batch(topic["id"], difficulty):
                    success += 1
                    logging.info(f"  ✅ Batch {batch + 1} done")
                else:
                    logging.error(f"  ❌ Batch {batch + 1} failed")
                
                time.sleep(2)  # avoid rate limiting

            logging.info(f"✅ {topic['name']} {difficulty}: {success * BATCH_SIZE} questions generated")

    logging.info("\n🎉 Bulk generation complete!")

if __name__ == "__main__":
    main()
    EOF