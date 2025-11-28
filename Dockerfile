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


# ==============================================
# OFFICIAL CADDY INSTALL (CLOUDSMITH)
# ==============================================
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
        | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
        | tee /etc/apt/sources.list.d/caddy-stable.list \
    && chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && chmod o+r /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*
# ==============================================


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

# Runtime deps
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

# Copy Caddy binary from builder
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Copy frontend dependencies
COPY --from=builder /app/node_modules /app/node_modules

# Copy app source
COPY . /app/

# Place Caddyfile and entrypoint
RUN mkdir -p /etc/caddy \
    && cp Caddyfile /etc/caddy/Caddyfile \
    && chmod +x scripts/entrypoint.sh

EXPOSE 80

CMD ["scripts/entrypoint.sh"]

