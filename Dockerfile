# Use official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install uv and project dependencies
RUN pip install --no-cache-dir uv
RUN uv sync

# Expose port from environment
ENV PORT=8080
EXPOSE ${PORT}

# Start FastAPI using uv
CMD ["uv", "run", "fastapi", "dev", "--host", "0.0.0.0", "--port", "8080"]

