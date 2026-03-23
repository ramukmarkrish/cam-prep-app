# Create a simple runner script
import requests
import time
import logging

logging.basicConfig(level=logging.INFO)

API_BASE_URL = "https://cma-api-923923178690.us-central1.run.app"

def main():
    # Health check
    response = requests.get(f"{API_BASE_URL}/health")
    print(f"✅ API Health: {response.json()}")

    # Get topics
    topics = requests.get(f"{API_BASE_URL}/topics").json()
    print(f"📚 Found {len(topics)} topics")

    # Generate questions for each topic
    for topic in topics:
        for difficulty in ["medium", "hard"]:
            try:
                print(f"🤖 Generating {difficulty} questions for {topic['name']}...")
                response = requests.get(
                    f"{API_BASE_URL}/topics/{topic['id']}/questions",
                    params={"difficulty": difficulty},
                    timeout=60
                )
                if response.status_code == 200:
                    questions = response.json()
                    print(f"✅ Got {len(questions)} questions")
                else:
                    print(f"❌ Failed: {response.status_code}")
            except Exception as e:
                print(f"❌ Error: {str(e)}")
            
            time.sleep(3)  # avoid rate limiting

    print("🎉 Done!")

if __name__ == "__main__":
    main()