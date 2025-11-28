#!/bin/bash
set -e

echo "Starting services..."

# Запускаем бэкенд в фоне
echo "Starting FastAPI backend..."
make run-render &

# Запускаем фронтенд в фоне  
echo "Starting frontend..."
cd frontend
VITE_API_URL=/api npx vite --host 0.0.0.0 --port 5173 &
cd ..

# Короткие ожидания (Render может иметь свои health checks)
echo "Waiting for services to start..."
sleep 10

# Проверяем что сервисы запустились
if curl -s http://127.0.0.1:8080/health >/dev/null; then
    echo "✓ Backend is running"
else
    echo "✗ Backend failed to start"
    exit 1
fi

if curl -s http://127.0.0.1:5173 >/dev/null; then
    echo "✓ Frontend is running"
else
    echo "✗ Frontend failed to start"
    exit 1
fi

echo "Starting Caddy..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
