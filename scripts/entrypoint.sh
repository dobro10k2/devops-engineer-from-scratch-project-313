#!/bin/sh
set -e

echo "Edit frontend vite.config.ts config file..."
sed -i '/preview: {/a\    allowedHosts: true,' node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts &

echo "Starting FastAPI backend..."
make run-render &

# Wait for backend
until curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done
echo "FastAPI is UP"

echo "Starting frontend (Vite)..."
API_URL=/api \
npx start-hexlet-project-devops-deploy-crud-frontend --host 0.0.0.0 &

# Wait for frontend
until curl -s http://127.0.0.1:5173 >/dev/null; do
  sleep 1
done
echo "Frontend is UP"

echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile

