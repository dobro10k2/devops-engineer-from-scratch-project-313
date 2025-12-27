#!/bin/sh
set -e

echo "=== Starting backend ==="
uv run fastapi dev --host 0.0.0.0 --port 8080 &

until curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done
echo "Backend is UP"

echo "=== Starting frontend ==="
npx start-hexlet-devops-deploy-crud-frontend --host 0.0.0.0 &

until curl -s http://127.0.0.1:5173 >/dev/null; do
  sleep 1
done
echo "Frontend is UP"

echo "=== Starting Caddy ==="
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
