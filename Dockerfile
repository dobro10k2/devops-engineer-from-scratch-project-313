# Dockerfile

FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl make npm debian-keyring debian-archive-keyring apt-transport-https gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (if required for other operations)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Caddy (official instructions)
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
    | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
    | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy

# Install @hexlet/project-url-shortener-frontend
#RUN npm install @hexlet/project-devops-deploy-crud-frontend

# Install uv for FastAPI
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set the path for uv
ENV PATH="/root/.local/bin:${PATH}"

# Copy the necessary files for installing dependencies
COPY pyproject.toml Makefile README.md /app/

# Install Python dependencies and generate uv.lock during the build
RUN uv sync

# Copy the rest of the project files
COPY . /app/

# Move Caddyfile
RUN mkdir -p /etc/caddy && cp Caddyfile /etc/caddy/Caddyfile

# Make the entrypoint.sh script executable
RUN chmod +x scripts/entrypoint.sh

# Expose port 80 for Nginx
EXPOSE 80

# Run Deploy
CMD ["scripts/entrypoint.sh"]
