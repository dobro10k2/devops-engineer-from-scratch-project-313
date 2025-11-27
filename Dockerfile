# Use Python base image
FROM python:3.12-slim

WORKDIR /app

# Install uv for Python dependency management
RUN pip install --no-cache-dir uv

# Copy project files
COPY . .

# Install Python dependencies
RUN uv sync

# Install Node.js 20.x (for running Hexlet frontend)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install frontend dependencies
RUN npm install --prefix frontend

# Expose FastAPI port
EXPOSE 8080

# Run backend and frontend
CMD sh -c "\
    uv run fastapi run --host 0.0.0.0 --port 8080 & \
    npx start-hexlet-devops-deploy-crud-frontend --port 4173 --host 0.0.0.0 \
"

