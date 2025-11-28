#!/bin/sh
set -e

echo "=== Patching frontend bundle ==="

find /app/node_modules/@hexlet/project-devops-deploy-crud-frontend/dist \
  -type f -name "*.js" \
  -exec sed -i 's|http://localhost:8080/api|https://dobro10k2.onrender.com/api|g' {} +

cat > /app/node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.js << 'EOF'
import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vite";

const API_URL = process.env.API_URL || 'https://dobro10k2.onrender.com';

export default defineConfig({
  plugins: [react()],
  preview: {
    allowedHosts: true,
    port: 5173,
    host: "0.0.0.0",
  },
  server: {
    allowedHosts: ["dobro10k2.onrender.com"],
    port: 5173,
    host: "0.0.0.0",
    proxy: {
      "/api": {
        target: API_URL,
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
EOF

echo "=== Starting backend ==="
uv run uvicorn app.main:app \
    --host 0.0.0.0 \
    --port 8080 \
    --proxy-headers \
    --forwarded-allow-ips="*" &

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
