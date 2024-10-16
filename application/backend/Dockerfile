FROM python:3.8-slim

WORKDIR /app

COPY app.py .
RUN pip install boto3 psycopg2

CMD ["python", "app.py"]
