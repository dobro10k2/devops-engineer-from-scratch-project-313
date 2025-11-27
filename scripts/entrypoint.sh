#!/bin/sh
set -e

echo "Starting FastAPI backend..."
make run-render &

# Wait for FastAPI
echo "Waiting for FastAPI..."
until curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done

echo "FastAPI is UP"

echo "Starting frontend..."
VITE_API_URL=/api \
  npx start-hexlet-devops-deploy-crud-frontend &

# Wait for frontend
until curl -s http://127.0.0.1:5173 >/dev/null; do
  sleep 1
done

echo "Frontend is UP"

echo "Starting Nginx..."
nginx -g "daemon off;"

