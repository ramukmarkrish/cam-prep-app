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

def generate_theory_cards(topic_name: str, cma_part: int, num_cards: int = 10):
    prompt = f"""
    You are a CMA exam expert and visual learning specialist.
    Generate {num_cards} theory flashcards for CMA topic: {topic_name} (Part {cma_part})

    Each card must be concise, memorable and exam-focused.

    Return ONLY valid JSON, no markdown:
    {{
        "cards": [
            {{
                "concept": "Variable Cost",
                "explanation": "Costs that change proportionally with production volume. Higher output = higher total cost.",
                "example": "Direct materials: making 100 units at $5/unit = $500. Making 200 units = $1,000.",
                "memory_trick": "Variable = Varies with Volume (3 V's!)",
                "formula": "Total Variable Cost = Cost per Unit × Units Produced",
                "category": "definition"
            }}
        ]
    }}

    Categories must be one of: definition, formula, concept, comparison, trick

    Make cards progressively harder — start with definitions, end with complex applications.
    Keep explanation under 2 sentences.
    Make memory tricks fun and sticky.
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