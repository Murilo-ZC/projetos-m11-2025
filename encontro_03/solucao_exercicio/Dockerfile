# Estágio de build
FROM python:3.11-slim AS builder

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


EXPOSE 8000

CMD ["python3","main.py"]
