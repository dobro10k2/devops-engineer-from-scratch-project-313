FROM python:3.12-slim

WORKDIR /app

COPY . .

# uv is the only installer
RUN pip install --no-cache-dir uv
RUN uv sync

ENV PORT=8080
EXPOSE ${PORT}

CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

