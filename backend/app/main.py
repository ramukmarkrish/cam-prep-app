import os
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from . import models
from .database import get_db
from .gemini import generate_questions
from pydantic import BaseModel
from datetime import date
from sqlalchemy import text

app = FastAPI(title="CMA Prep MVP", version="1.0.0")

@app.get("/health")
def health(db: Session = Depends(get_db)):
    # Actually test DB connection
    try:
        db.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"DB unavailable: {str(e)}")


@app.get("/topics")
def get_topics(part: int = None, db: Session = Depends(get_db)):
    query = db.query(models.Topic)
    if part:
        query = query.filter(models.Topic.cma_part == part)
    return query.order_by(models.Topic.cma_part, models.Topic.id).all()

@app.get("/topics/{topic_id}/questions")
def get_questions(
    topic_id: int,
    difficulty: str = "medium",
    user_id: str = "default_user",
    db: Session = Depends(get_db)
):
    topic = db.query(models.Topic).filter(models.Topic.id == topic_id).first()
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")

    available = db.query(models.Question).filter(
        models.Question.topic_id == topic_id,
        models.Question.difficulty == difficulty,
        models.Question.times_served < 10
    ).limit(5).all()

    if len(available) < 3:
        try:
            result = generate_questions(
                topic_name=topic.name,
                cma_part=topic.cma_part,
                difficulty=difficulty,
                num_questions=5
            )
            for q in result["questions"]:
                question = models.Question(
                    topic_id=topic_id,
                    text=q["text"],
                    type=q["type"],
                    difficulty=q["difficulty"],
                    explanation=q["explanation"],
                    source="gemini"
                )
                db.add(question)
                db.flush()

                for i, opt in enumerate(q["options"]):
                    answer = models.Answer(
                        question_id=question.id,
                        text=opt,
                        is_correct=(i == q["correct_index"])
                    )
                    db.add(answer)

            db.commit()

            available = db.query(models.Question).filter(
                models.Question.topic_id == topic_id,
                models.Question.difficulty == difficulty,
            ).limit(5).all()

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Gemini error: {str(e)}")

    for q in available:
        q.times_served += 1
    db.commit()

    return [
        {
            "id": q.id,
            "text": q.text,
            "type": q.type,
            "difficulty": q.difficulty,
            "answers": [
                {"id": a.id, "text": a.text}
                for a in q.answers
            ]
        }
        for q in available
    ]

class AnswerSubmit(BaseModel):
    user_id: str
    question_id: int
    topic_id: int
    selected_answer_id: int
    time_taken: int

@app.post("/submit")
def submit_answer(payload: AnswerSubmit, db: Session = Depends(get_db)):
    answer = db.query(models.Answer).filter(
        models.Answer.id == payload.selected_answer_id
    ).first()
    if not answer:
        raise HTTPException(status_code=404, detail="Answer not found")

    is_correct = answer.is_correct

    progress = models.UserProgress(
        user_id=payload.user_id,
        question_id=payload.question_id,
        topic_id=payload.topic_id,
        is_correct=is_correct,
        time_taken=payload.time_taken
    )
    db.add(progress)

    stats = db.query(models.UserTopicStats).filter(
        models.UserTopicStats.user_id == payload.user_id,
        models.UserTopicStats.topic_id == payload.topic_id
    ).first()

    if not stats:
        stats = models.UserTopicStats(
            user_id=payload.user_id,
            topic_id=payload.topic_id,
            current_difficulty="medium",
            accuracy_rate=0.0,
            questions_seen=0,
            confidence_score=0.0
        )
        db.add(stats)
        db.flush()

    stats.questions_seen += 1
    stats.last_studied = date.today()

    recent = db.query(models.UserProgress).filter(
        models.UserProgress.user_id == payload.user_id,
        models.UserProgress.topic_id == payload.topic_id
    ).order_by(models.UserProgress.answered_at.desc()).limit(20).all()

    if recent:
        stats.accuracy_rate = sum(1 for r in recent if r.is_correct) / len(recent)

    if stats.questions_seen >= 15:
        if stats.accuracy_rate >= 0.70 and stats.current_difficulty == "medium":
            stats.current_difficulty = "hard"
        elif stats.accuracy_rate < 0.50 and stats.current_difficulty == "hard":
            stats.current_difficulty = "medium"

    db.commit()

    question = db.query(models.Question).filter(
        models.Question.id == payload.question_id
    ).first()

    return {
        "is_correct": is_correct,
        "explanation": question.explanation if question else "",
        "accuracy_rate": round(stats.accuracy_rate * 100, 1),
        "current_difficulty": stats.current_difficulty
    }

@app.get("/progress/{user_id}")
def get_progress(user_id: str, db: Session = Depends(get_db)):
    stats = db.query(models.UserTopicStats).filter(
        models.UserTopicStats.user_id == user_id
    ).all()
    topics = {t.id: t for t in db.query(models.Topic).all()}
    return [
        {
            "topic": topics[s.topic_id].name,
            "cma_part": topics[s.topic_id].cma_part,
            "icon": topics[s.topic_id].icon,
            "difficulty": s.current_difficulty,
            "accuracy": round(s.accuracy_rate * 100, 1),
            "questions_seen": s.questions_seen,
            "last_studied": s.last_studied
        }
        for s in stats if s.topic_id in topics
    ]