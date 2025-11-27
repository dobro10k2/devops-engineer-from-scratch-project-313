# Dockerfile

FROM python:3.12-slim

WORKDIR /app

# Install uv for Python dependency management
RUN pip install --no-cache-dir uv

# Copy all project files
COPY . .

# Install Python dependencies (no --frozen because uv.lock is ignored)
RUN uv sync

# Install Node.js 20.x (for frontend build)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install frontend dependencies
RUN npm install --prefix frontend

# Build frontend into frontend/dist
RUN npm run build --prefix frontend

# Install Caddy web server
RUN apt-get update && apt-get install -y caddy

# Expose port
ENV PORT=8080
EXPOSE 8080

# Run FastAPI and Caddy
CMD ["sh", "-c", "uv run fastapi run --host 0.0.0.0 --port 8080 & caddy run --config /app/Caddyfile"]

