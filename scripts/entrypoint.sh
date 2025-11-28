#!/bin/sh

set -e

echo "Edit frontend vite.config.ts config file..."
sed -i '/preview: {/a\    allowedHosts: true,' node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts &
cat > node_modules/@hexlet/project-devops-deploy-crud-frontend/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'

export default defineConfig({
  base: '/',
  server: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: [
      'dobro10k2.onrender.com',
      'localhost',
      '127.0.0.1'
    ],
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8080',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
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
