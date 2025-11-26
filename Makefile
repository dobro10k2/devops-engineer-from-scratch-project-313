.PHONY: install run test lint fmt clean

# Install dependencies
install:
	uv sync

# Run FastAPI app on port 8080
run:
	uv run fastapi dev --host 0.0.0.0 --port 8080

# Run tests with PYTHONPATH to find app package
test:
	PYTHONPATH=. uv run pytest -q

# Run linter
lint:
	uv run ruff check .

# Format code
fmt:
	uv run ruff format .

# Clean uv/Ruff cache
clean:
	rm -rf .ruff_cache uv.lock

