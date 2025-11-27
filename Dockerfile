# Dockerfile — production build for Render

# --------------------------
# 1. Backend + Frontend build stage
# --------------------------
FROM python:3.12-slim AS builder

WORKDIR /app

# Install uv (allowed usage of pip ONLY for installing uv)
RUN pip install --no-cache-dir uv

# Install Node.js 20 (required for Hexlet frontend)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Install Python deps
RUN uv sync --frozen

# Install frontend deps
RUN npm install --prefix frontend

# Build frontend WITHOUT preview (Hexlet cli handles prod build)
RUN npx @hexlet/project-devops-deploy-crud-frontend build --prefix frontend

# --------------------------
# 2. Production image with Caddy
# --------------------------
FROM python:3.12-slim

WORKDIR /app

# Install uv
RUN pip install --no-cache-dir uv

# Install Caddy
RUN apt-get update && apt-get install -y caddy && rm -rf /var/lib/apt/lists/*

# Copy backend files
COPY . .

# Copy built frontend from builder stage
COPY --from=builder /app/frontend/dist ./frontend/dist

# Sync python deps again (no dev deps)
RUN uv sync --frozen

ENV PORT=8080
EXPOSE 8080

# Start FastAPI + Caddy
CMD ["sh", "-c", "uv run fastapi run --host 0.0.0.0 --port 8080 & caddy run --config /app/Caddyfile"]

