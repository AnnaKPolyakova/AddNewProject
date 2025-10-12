#!/bin/bash
set -e

PROJECT_NAME=$1
cd "$PROJECT_NAME"
source venv/bin/activate

echo "⚙️ Настраиваем Django settings..."

SETTINGS_FILE="$PROJECT_NAME/settings.py"

## Удаляем дефолтную секцию DATABASES
#sed -i.bak '/^DATABASES =/,/^}/d' "$SETTINGS_FILE"

# Добавляем поддержку dotenv и PostgreSQL
#cat >> "$SETTINGS_FILE" <<'EOF'
#
#import os
#from dotenv import load_dotenv
#load_dotenv()
#
#DATABASES = {
#    'default': {
#        'ENGINE': 'django.db.backends.postgresql',
#        'NAME': os.getenv('DB_NAME'),
#        'USER': os.getenv('DB_USER'),
#        'PASSWORD': os.getenv('DB_PASSWORD'),
#        'HOST': os.getenv('DB_HOST'),
#        'PORT': os.getenv('DB_PORT', '5432'),
#    }
#}
#EOF
SETTINGS_FILE="$PROJECT_NAME/settings.py"

SETTINGS_FILE="$PROJECT_NAME/settings.py"

# Создаём временный файл
TMP_FILE=$(mktemp)

awk '
  BEGIN {in_db=0}
  /^DATABASES\s*=/ {
      print "# PostgreSQL через .env"
      print "DATABASES = {"
      print "    '\''default'\'': {"
      print "        '\''ENGINE'\'': '\''django.db.backends.postgresql'\'',"
      print "        '\''NAME'\'': os.getenv('\''DB_NAME'\'', '\''default_db'\''),"
      print "        '\''USER'\'': os.getenv('\''DB_USER'\'', '\''user'\''),"
      print "        '\''PASSWORD'\'': os.getenv('\''DB_PASSWORD'\'', '\''password'\''),"
      print "        '\''HOST'\'': os.getenv('\''DB_HOST'\'', '\''localhost'\''),"
      print "        '\''PORT'\'': os.getenv('\''DB_PORT'\'', '\''5432'\''),"
      print "    }"
      print "}"
      in_db=1
      next
  }
  in_db && /^\}/ {in_db=0; next}  # пропускаем старый блок
  !in_db {print $0}
' "$SETTINGS_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$SETTINGS_FILE"

# Добавляем импорты dotenv в начало, если их ещё нет
grep -q "from dotenv import load_dotenv" "$SETTINGS_FILE" || sed -i '' "1i\\
import os\nfrom dotenv import load_dotenv\nload_dotenv()" "$SETTINGS_FILE"


echo "✅ Django настроен."
