# Dockerfile

# Stage 1: Backend (FastAPI) setup
FROM python:3.12-slim AS backend

WORKDIR /app

# Install uv and other dependencies
RUN pip install --no-cache-dir uv

# Install Node.js (required for frontend build)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Nginx
RUN apt-get update && apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Sync Python dependencies
RUN uv sync --frozen

# Install frontend dependencies and build
RUN npm install --prefix frontend
RUN npm run build --prefix frontend

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose necessary ports
ENV PORT=80
EXPOSE 80

# Command to start FastAPI app and Nginx
CMD ["sh", "-c", "uv run fastapi dev --host 0.0.0.0 --port 8080 & nginx -g 'daemon off;'"]

