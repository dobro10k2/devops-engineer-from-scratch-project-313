###############################################
# STAGE 1 — Builder
###############################################
FROM python:3.12-slim AS builder

WORKDIR /app

# Install system dependencies
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

# Install Node.js (Debian)
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Caddy from official .deb
RUN curl -LO "https://github.com/caddyserver/caddy/releases/latest/download/caddy_2.7.6_linux_amd64.deb" \
    && dpkg -i caddy_*.deb \
    && rm caddy_*.deb

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Copy dependency files
COPY pyproject.toml Makefile README.md ./

# Install Python deps
RUN uv sync

# Install frontend deps
RUN npm install @hexlet/project-devops-deploy-crud-frontend


###############################################
# STAGE 2 — Runtime
###############################################
FROM python:3.12-slim AS runtime

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
ENV PATH="/root/.local/bin:$PATH"

COPY --from=builder /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy Caddy binary
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Copy frontend node_modules
COPY --from=builder /app/node_modules /app/node_modules

# Copy project files
COPY . /app/

RUN mkdir -p /etc/caddy \
    && cp Caddyfile /etc/caddy/Caddyfile \
    && chmod +x scripts/entrypoint.sh

EXPOSE 80

CMD ["scripts/entrypoint.sh"]

