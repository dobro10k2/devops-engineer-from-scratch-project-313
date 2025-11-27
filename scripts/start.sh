#!/bin/sh

# Запускаем FastAPI в фоновом режиме
echo "Starting FastAPI application..."
make start &

# Ждем немного, чтобы FastAPI успел запуститься
while ! curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done

# Запускаем Nginx
echo "Starting Nginx..."
nginx -g "daemon off;"

