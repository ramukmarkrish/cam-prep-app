from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests
import logging

# Your Cloud Run API URL
API_BASE_URL = "https://cma-api-923923178690.us-central1.run.app"

def get_all_topics():
    """Fetch all topics from API"""
    response = requests.get(f"{API_BASE_URL}/topics")
    topics = response.json()
    logging.info(f"Found {len(topics)} topics")
    return topics

def generate_questions_for_topic(topic_id: int, topic_name: str, difficulty: str):
    """Generate questions for a single topic"""
    try:
        response = requests.get(
            f"{API_BASE_URL}/topics/{topic_id}/questions",
            params={
                "difficulty": difficulty,
                "user_id": "airflow_scheduler"
            },
            timeout=60  # Gemini can take time
        )
        if response.status_code == 200:
            questions = response.json()
            logging.info(f"✅ Generated {len(questions)} {difficulty} questions for {topic_name}")
        else:
            logging.error(f"❌ Failed for {topic_name}: {response.status_code}")
    except Exception as e:
        logging.error(f"❌ Error for {topic_name}: {str(e)}")

def generate_all_questions(**context):
    """Main function — generates questions for all topics"""
    topics = get_all_topics()
    
    total_generated = 0
    for topic in topics:
        for difficulty in ["medium", "hard"]:
            generate_questions_for_topic(
                topic_id=topic["id"],
                topic_name=topic["name"],
                difficulty=difficulty
            )
            total_generated += 1
    
    logging.info(f"🎉 Done! Generated questions for {total_generated} topic/difficulty combinations")
    return total_generated

def check_api_health(**context):
    """Check if API is healthy before generating"""
    response = requests.get(f"{API_BASE_URL}/health")
    if response.status_code != 200:
        raise Exception(f"API is not healthy! Status: {response.status_code}")
    logging.info("✅ API is healthy")

# DAG definition
default_args = {
    "owner": "ram",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": False,
}

dag = DAG(
    "generate_cma_questions_nightly",
    default_args=default_args,
    description="Generate fresh CMA questions using Gemini AI",
    schedule_interval="0 23 * * *",  # 11pm every night
    start_date=datetime(2026, 3, 22),
    catchup=False,
    tags=["cma", "gemini", "questions"]
)

# Tasks
health_check = PythonOperator(
    task_id="check_api_health",
    python_callable=check_api_health,
    dag=dag
)

generate_questions = PythonOperator(
    task_id="generate_questions",
    python_callable=generate_all_questions,
    dag=dag
)

# Task dependencies
health_check >> generate_questions