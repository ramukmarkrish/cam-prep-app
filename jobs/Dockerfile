FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

RUN pip install requests psycopg2-binary

COPY generate_questions.py .

CMD ["python", "generate_questions.py"]