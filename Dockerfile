# ================================
# STAGE 1 — Builder
# ================================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        make \
        npm \
        gnupg \
        debian-keyring \
        debian-archive-keyring \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Caddy
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
    | gpg --dearmor -o /usr/share/keyrings/caddy.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
    | tee /etc/apt/sources.list.d/caddy.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Copy only dependency-related files
COPY pyproject.toml Makefile README.md ./

# Install Python deps (cached)
RUN uv sync

# Install frontend package (cached)
RUN npm install @hexlet/project-devops-deploy-crud-frontend


# ================================
# STAGE 2 — Runtime
# ================================
FROM python:3.12-slim AS runtime

WORKDIR /app

# Runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy uv environment
COPY --from=builder /root/.local /root/.local
ENV PATH="/root/.local/bin:$PATH"

# Python virtual env
COPY --from=builder /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy Caddy binary
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Copy frontend dependencies
COPY --from=builder /app/node_modules /app/node_modules

# Copy source code
COPY . /app/

# Caddy config
RUN mkdir -p /etc/caddy \
    && cp Caddyfile /etc/caddy/Caddyfile \
    && chmod +x scripts/entrypoint.sh

EXPOSE 80

CMD ["scripts/entrypoint.sh"]
