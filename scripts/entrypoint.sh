#!/bin/sh

# Start FastAPI application in the background
echo "Starting FastAPI application..."
make run-render &

# Wait a bit for FastAPI to start
while ! curl -s http://127.0.0.1:8080/health >/dev/null; do
  sleep 1
done

# Start the frontend (Hexlet URL shortener) in the background
echo "Starting frontend..."
npx start-hexlet-devops-deploy-crud-frontend &

# Wait a bit for frontend to start
while ! curl -s http://127.0.0.1:5173/health >/dev/null; do
  sleep 1
done

echo "Frontend finished loading..."

# Start Nginx
echo "Starting Nginx..."
nginx -g "daemon off;"

