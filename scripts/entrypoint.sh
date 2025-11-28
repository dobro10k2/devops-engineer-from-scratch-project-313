#!/bin/sh

set -e

echo "Patching built frontend bundle URLs..."
sed -i 's|http://localhost:8080/api|https://dobro10k2.onrender.com/api|g' \
  /app/node_modules/@hexlet/project-devops-deploy-crud-frontend/dist/assets/index-*.js

echo "Starting services..."

# Запускаем бэкенд в фоне
echo "Starting FastAPI backend..."
make run-render &

# Wait for backend
until curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done
echo "FastAPI is UP"

# Запускаем фронтенд в фоне  
echo "Starting frontend..."
VITE_API_URL=/api npx start-hexlet-devops-deploy-crud-frontend &

# Wait for frontend
until curl -s http://127.0.0.1:5173 >/dev/null; do
  sleep 1
done
echo "Frontend is UP"

echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
