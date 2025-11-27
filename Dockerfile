# Dockerfile

FROM python:3.12-slim AS backend

WORKDIR /app

# Install uv
RUN pip install --no-cache-dir uv

# Copy project files
COPY . .

# Sync Python dependencies
RUN uv sync --frozen

# Install Node.js (required to build frontend)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install frontend
RUN npm install --prefix frontend

# Build frontend
RUN npm run build --prefix frontend

# Install Caddy
RUN apt-get update && apt-get install -y caddy

# Expose port
ENV PORT=8080
EXPOSE 8080

# Run FastAPI + Caddy
CMD ["sh", "-c", "uv run fastapi run --host 0.0.0.0 --port 8080 & caddy run --config /app/Caddyfile"]

