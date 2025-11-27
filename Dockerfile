# Dockerfile

FROM python:3.12-slim

WORKDIR /app

# Install necessary packages and utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl make nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (if required for other operations)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install @hexlet/project-url-shortener-frontend
RUN npm install @hexlet/project-devops-deploy-crud-frontend

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

# Move Nginx configuration to the correct directory
RUN mv nginx.conf /etc/nginx/nginx.conf

# Make the entrypoint.sh script executable
RUN chmod +x scripts/entrypoint.sh

# Expose port 80 for Nginx
EXPOSE 80

# Run Deploy
CMD ["scripts/entrypoint.sh"]
