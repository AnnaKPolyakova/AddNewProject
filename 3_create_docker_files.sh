#!/bin/bash
set -e

PROJECT_NAME=$1
cd "$PROJECT_NAME"
source venv/bin/activate

echo "🐳 Создаём docker-compose.yml, docker-compose-local.yml и Dockerfile..."

cat > docker-compose.yml <<EOF
version: '3.9'

services:
  db:
    image: postgres:16.1-alpine
    container_name: ${PROJECT_NAME}_db
    restart: always
    environment:
      POSTGRES_DB: \${DB_NAME}
      POSTGRES_USER: \${DB_USER}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    ports:
      - ${DB_PORT}:5432
    volumes:
      - ./docker/pg/data:/var/lib/postgresql/data
      - ./docker/pg/tmp:/tmp
    env_file:
      - .env
    networks:
      - app_network

  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}_web
    command: bash -c "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      - db
    networks:
      - app_network

  networks:
    ${PROJECT_NAME}_network:
EOF

cat > docker-compose-local.yml <<EOF
version: '3.9'

services:
  db:
    image: postgres:16.1-alpine
    container_name: ${PROJECT_NAME}_db
    restart: always
    environment:
      POSTGRES_DB: \${DB_NAME}
      POSTGRES_USER: \${DB_USER}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    ports:
      - ${DB_PORT}:5432
    volumes:
      - ./docker/pg/data:/var/lib/postgresql/data
      - ./docker/pg/tmp:/tmp
    env_file:
      - .env
    networks:
      - app_network

  networks:
    ${PROJECT_NAME}_network:
EOF

cat > Dockerfile <<EOF
FROM python:3.11.4-bullseye

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

WORKDIR /code
RUN mkdir /code/logs && touch /code/logs/log.log

RUN pip install poetry

COPY poetry.lock pyproject.toml /code/
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi

RUN apt update
RUN apt install -y gettext
COPY . /code
RUN django-admin compilemessages
CMD ["daphne", "-b", "0.0.0.0", "-p", "8011", "server.asgi:application"]

EOF

echo "✅ Docker файлы созданы."
