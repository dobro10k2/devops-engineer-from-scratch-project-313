# Фронтенд стадия
FROM node:20-alpine as frontend
WORKDIR /frontend
RUN npm install @hexlet/project-devops-deploy-crud-frontend
# RUN npm run build если требуется

# Бэкенд стадия
FROM python:3.12-alpine

WORKDIR /app

# Устанавливаем только необходимые пакеты
RUN apk add --no-cache curl

# Устанавливаем Caddy
RUN curl -L -o /usr/bin/caddy "https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64" \
    && chmod +x /usr/bin/caddy

# Устанавливаем uv и зависимости
RUN pip install uv
COPY pyproject.toml Makefile README.md ./
RUN uv sync

# Копируем фронтенд
COPY --from=frontend /frontend/node_modules/@hexlet/project-devops-deploy-crud-frontend ./frontend

# Копируем исходный код
COPY . .

# Настройки
RUN cp Caddyfile /etc/caddy/Caddyfile
RUN chmod +x scripts/entrypoint.sh

EXPOSE 80

CMD ["scripts/entrypoint.sh"]
