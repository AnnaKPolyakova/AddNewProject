#!/bin/bash
set -e

PROJECT_NAME=$1
cd "$PROJECT_NAME"
source venv/bin/activate

echo "🔑 Создаём .env файл..."
echo "📂 Текущая директория: $(pwd)"

SECRET_KEY=$(poetry run python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')

cat > .env <<EOF
DEBUG=True
SECRET_KEY=$SECRET_KEY
DB_NAME=${PROJECT_NAME}_db
DB_USER=${PROJECT_NAME}_user
DB_PASSWORD=${PROJECT_NAME}_password
DB_HOST=db
DB_PORT=5432
EOF

echo "✅ .env создан."
