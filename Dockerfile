FROM python:3.14-slim AS base

WORKDIR /app

# ---------------------------------------
# 1. Install system deps (ONE apt update)
# ---------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        make \
        gnupg \
        npm \
        debian-keyring \
        debian-archive-keyring \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------
# 2. Install Node.js from Debian repo
# (faster than NodeSource script)
# ---------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------
# 3. Install Caddy
# ---------------------------------------
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
        | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
        | tee /etc/apt/sources.list.d/caddy-stable.list \
    && chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && chmod o+r /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------
# 4. Install uv
# ---------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# ---------------------------------------
# 5. Copy minimal files to install deps
# ---------------------------------------
COPY pyproject.toml Makefile README.md /app/

# ---------------------------------------
# 6. Install Python deps (cached)
# ---------------------------------------
RUN uv sync

# ---------------------------------------
# 7. Install frontend package (cached)
# ---------------------------------------
RUN npm install @hexlet/project-devops-deploy-crud-frontend

# ---------------------------------------
# 8. Copy the whole application
# ---------------------------------------
COPY . /app/

# ---------------------------------------
# 9. Caddy config + permissions
# ---------------------------------------
RUN mkdir -p /etc/caddy \
    && cp Caddyfile /etc/caddy/Caddyfile \
    && chmod +x scripts/entrypoint.sh

EXPOSE 80

CMD ["scripts/entrypoint.sh"]

