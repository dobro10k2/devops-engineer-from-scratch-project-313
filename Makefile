.PHONY: install dev run test lint fmt fix clean

install:
	uv sync

run:
	uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080

dev:
	npx concurrently \
		"uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080" \
		"npx @hexlet/project-devops-deploy-crud-frontend --host 0.0.0.0"

test:
	PYTHONPATH=. uv run pytest -q

lint:
	uv run ruff check .

fix:
	uv run ruff check . --fix

fmt:
	uv run ruff format .

clean:
	rm -rf .ruff_cache uv.lock
