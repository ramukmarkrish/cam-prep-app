from sqlalchemy import Column, Integer, String, Boolean, Text, Float, ForeignKey, DateTime, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

class Topic(Base):
    __tablename__ = "topics"
    id          = Column(Integer, primary_key=True)
    name        = Column(String(200), nullable=False)
    cma_part    = Column(Integer, nullable=False)
    description = Column(Text)
    icon        = Column(String(50))
    syllabus    = Column(Text)
    weightage   = Column(Integer)
    created_at  = Column(DateTime, server_default=func.now())
    questions   = relationship("Question", back_populates="topic")

class Question(Base):
    __tablename__ = "questions"
    id            = Column(Integer, primary_key=True)
    topic_id      = Column(Integer, ForeignKey("topics.id"))
    text          = Column(Text, nullable=False)
    type          = Column(String(20))
    difficulty    = Column(String(10))
    explanation   = Column(Text)
    source        = Column(String(20), default="gemini")
    times_served  = Column(Integer, default=0)
    quality_score = Column(Float, default=0.0)
    created_at    = Column(DateTime, server_default=func.now())
    topic         = relationship("Topic", back_populates="questions")
    answers       = relationship("Answer", back_populates="question")

class Answer(Base):
    __tablename__ = "answers"
    id          = Column(Integer, primary_key=True)
    question_id = Column(Integer, ForeignKey("questions.id"))
    text        = Column(Text, nullable=False)
    is_correct  = Column(Boolean, default=False)
    question    = relationship("Question", back_populates="answers")

class UserProgress(Base):
    __tablename__ = "user_progress"
    id          = Column(Integer, primary_key=True)
    user_id     = Column(String(100), nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"))
    topic_id    = Column(Integer, ForeignKey("topics.id"))
    is_correct  = Column(Boolean)
    time_taken  = Column(Integer)
    answered_at = Column(DateTime, server_default=func.now())

class UserTopicStats(Base):
    __tablename__ = "user_topic_stats"
    id                 = Column(Integer, primary_key=True)
    user_id            = Column(String(100), nullable=False)
    topic_id           = Column(Integer, ForeignKey("topics.id"))
    current_difficulty = Column(String(10), default="medium")
    accuracy_rate      = Column(Float, default=0.0)
    questions_seen     = Column(Integer, default=0)
    confidence_score   = Column(Float, default=0.0)
    last_studied       = Column(Date)

class UserStreak(Base):
    __tablename__ = "user_streaks"
    id             = Column(Integer, primary_key=True)
    user_id        = Column(String(100), nullable=False, unique=True)
    current_streak = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    total_points   = Column(Integer, default=0)
    last_activity  = Column(Date)

class StudySession(Base):
    __tablename__ = "study_sessions"
    id                  = Column(Integer, primary_key=True)
    user_id             = Column(String(100), nullable=False)
    started_at          = Column(DateTime, server_default=func.now())
    ended_at            = Column(DateTime)
    duration_mins       = Column(Integer)
    questions_attempted = Column(Integer, default=0)
    correct_answers     = Column(Integer, default=0)
    xp_earned          = Column(Integer, default=0)