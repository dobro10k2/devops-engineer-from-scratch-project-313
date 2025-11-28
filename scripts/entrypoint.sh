#!/bin/sh
set -e

echo "Starting FastAPI backend..."
make run-render &

# Wait for backend
until curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done
echo "FastAPI is UP"

echo "Starting frontend (Vite)..."
npx @hexlet/project-devops-deploy-crud-frontend &

# Wait for frontend
until curl -s http://127.0.0.1:5173 >/dev/null; do
  sleep 1
done
echo "Frontend is UP"

echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile

