# Makefile
.PHONY: install run test lint fmt clean dev fix

# Install Python dependencies
install:
	uv sync

# Run backend only (with .env loaded)
run:
	uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080

# Run backend on render
run-render:
	uv run fastapi dev --host 0.0.0.0 --port 8081


# Run backend and frontend together
dev:
	npx concurrently \
	    "uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080" \
	    "npx @hexlet/project-devops-deploy-crud-frontend"

# Run tests
test:
	PYTHONPATH=. uv run pytest -q

# Run linter
lint:
	uv run ruff check .

# Auto-fix code issues
fix:
	uv run ruff check . --fix

# Format code
fmt:
	uv run ruff format .

# Clean caches
clean:
	rm -rf .ruff_cache uv.lock

