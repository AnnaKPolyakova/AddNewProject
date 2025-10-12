#!/bin/bash
set -e

PROJECT_NAME=$1
echo "🚀 Создаём структуру для проекта '$PROJECT_NAME'..."

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Создаем виртуальное окружение
PYTHON_BIN="/usr/local/bin/python3.13"

# Создаем виртуальное окружение с нужным Python
if [ ! -d "venv" ]; then
  echo "🐍 Создаём виртуальное окружение Python 3.13..."
  $PYTHON_BIN -m venv venv
  echo "✅ Виртуальное окружение создано."
fi

# Активируем виртуальное окружение
echo "🔗 Активируем виртуальное окружение..."
source venv/bin/activate

# Создаём файл README.md и .env
touch README.md

echo "📦 Инициализация Poetry..."
pip install --upgrade pip
pip install poetry

# Обновляем Poetry и устанавливаем зависимости
poetry init --no-interaction --name "$PROJECT_NAME" --dependency django --dependency psycopg2-binary load-dotenv

poetry config virtualenvs.in-project true --local

poetry install --no-root

# Генерация SECRET_KEY
SECRET_KEY=$(poetry run python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')

echo "SECRET_KEY=$SECRET_KEY" > .env
echo "DATABASE_URL=postgresql://user:password@localhost:5432/$PROJECT_NAME" >> .env

# Инициализация проекта Django
echo "🧱 Создаём Django проект..."
poetry run django-admin startproject "$PROJECT_NAME" .

echo "✅ Базовая структура создана с Python 3.13."
