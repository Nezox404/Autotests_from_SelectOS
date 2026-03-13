
set -e # Прерывать скрипт при любой ошибке

echo "=== Тест 1: Установка PostgreSQL из репозитория ==="
sudo apt update
sudo apt install -y postgresql postgresql-contrib
echo "Установка завершена."

echo "=== Тест 2: Проверка статуса сервиса ==="
# Проверяем, что сервис запущен и включен в автозагрузку
sudo systemctl is-enabled postgresql --quiet
if [ $? -eq 0 ]; then
    echo "Сервис включен в автозагрузку."
else
    echo "Ошибка: Сервис не включен в автозагрузку."
    exit 1
fi

sudo systemctl is-active postgresql --quiet
if [ $? -eq 0 ]; then
    echo "Сервис активен (запущен)."
else
    echo "Ошибка: Сервис не запущен."
    exit 1
fi

echo "=== Тест 3: Функциональная проверка (создание БД и таблицы) ==="
# Создаем тестовую базу данных
sudo -u postgres psql -c "CREATE DATABASE testdb;" > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ База данных 'testdb' создана."
else
    echo "Ошибка создания БД."
    exit 1
fi

# Подключаемся к БД и создаем таблицу
sudo -u postgres psql -d testdb -c "CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);" > /dev/null
if [ $? -eq 0 ]; then
    echo "Таблица 'users' создана в 'testdb'."
else
    echo "Ошибка создания таблицы."
    exit 1
fi

# Вставляем данные
sudo -u postgres psql -d testdb -c "INSERT INTO users (name) VALUES ('Test User');" > /dev/null
if [ $? -eq 0 ]; then
    echo "Данные вставлены."
else
    echo "Ошибка вставки данных."
    exit 1
fi

# Читаем данные
RESULT=$(sudo -u postgres psql -d testdb -t -c "SELECT count(*) FROM users;")
# Убираем пробелы
RESULT=$(echo $RESULT | xargs)
if [ "$RESULT" -eq "1" ]; then
    echo "Данные прочитаны корректно. Найдено записей: $RESULT"
else
    echo "Ошибка чтения данных."
    exit 1
fi

echo "=== Очистка ==="
sudo -u postgres psql -c "DROP DATABASE testdb;" > /dev/null
echo "Тестовая БД удалена."
echo "Все тесты пройдены успешно! PostgreSQL совместим с SELECTOS."
