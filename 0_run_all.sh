#!/bin/bash
set -e

PROJECT_NAME=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd ../new

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Укажите имя проекта. Пример: bash 0_run_all.sh myproject"
  exit 1
fi

export PROJECT_NAME

## Проверяем, существует ли каталог проекта
#if [ -d "$PROJECT_NAME" ]; then
#  echo "⚠️ Проект с именем '$PROJECT_NAME' уже существует. Ничего не создано."
#  exit 1
#fi

echo "📂 Текущая директория: $(pwd)"
echo "📂 Создаём проект '$PROJECT_NAME'..."

#bash $SCRIPT_DIR/1_create_structure.sh "$PROJECT_NAME"
#bash $SCRIPT_DIR/2_create_env.sh "$PROJECT_NAME"
#bash $SCRIPT_DIR/3_create_docker_files.sh "$PROJECT_NAME"
bash $SCRIPT_DIR/4_configure_django.sh "$PROJECT_NAME"

echo "✅ Всё готово! Проект '$PROJECT_NAME' создан."
echo "👉 Запусти: docker-compose up --build"
