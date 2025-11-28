#!/bin/sh

set -e

echo "Edit frontend vite.config.ts config file..."
sed -i '/preview: {/a\    allowedHosts: true,' node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts &
cat > node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts << 'EOF'
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
    allowedHosts: ["dobro10k2.onrender.com"],   // <-- ОБЯЗАТЕЛЬНО!
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

cat node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts

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
