#!/bin/sh

# Запускаем FastAPI в фоновом режиме
echo "Starting FastAPI application..."
make run-render &

# Ждем немного, чтобы FastAPI успел запуститься
while ! curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done

npx start-hexlet-devops-deploy-crud-frontend & while ! curl -s http://127.0.0.1:5173/health >/dev/null; do sleep 1 done echo "start-hexlet-devops-deploy-crud-frontend finished..."

# Запускаем Nginx
echo "Starting Nginx..."
nginx -g "daemon off;"

