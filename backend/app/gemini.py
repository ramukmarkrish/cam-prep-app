import os
import json
import pathlib
from google import genai
from dotenv import load_dotenv

env_path = pathlib.Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))

def generate_questions(topic_name: str, cma_part: int,
                       difficulty: str, num_questions: int = 5):
    prompt = f"""
    You are a CMA (Certified Management Accountant) exam expert.
    Generate {num_questions} exam-style questions for:

    Topic: {topic_name}
    CMA Part: {cma_part}
    Difficulty: {difficulty}

    Student profile:
    - Already has strong theoretical knowledge
    - Needs exam-style application questions
    - {"Focus on application and calculations" if difficulty == "medium"
       else "Mirror actual CMA exam style with tricky distractors"}

    Return ONLY valid JSON, no markdown, no extra text:
    {{
        "questions": [
            {{
                "text": "full question text here",
                "type": "mcq",
                "difficulty": "{difficulty}",
                "options": [
                    "A. option text",
                    "B. option text",
                    "C. option text",
                    "D. option text"
                ],
                "correct_index": 0,
                "explanation": "detailed explanation of why answer is correct and why others are wrong"
            }}
        ]
    }}
    """

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt
    )

    text = response.text.strip()
    if "```" in text:
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]

    return json.loads(text.strip())