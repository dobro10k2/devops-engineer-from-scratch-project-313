.PHONY: install dev run test lint fmt fix clean setup

install:
	uv sync

run:
	uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080

dev:
	npx concurrently \
		"uv run --env-file .env fastapi dev --host 0.0.0.0 --port 8080" \
		"npx @hexlet/project-devops-deploy-crud-frontend --host 0.0.0.0"

setup:
	@if [ "$$CI" = "true" ]; then \
		echo "CI mode: installing deps via pip"; \
		pip install -r requirements.txt; \
	else \
		echo "Local/Prod mode: installing deps via uv"; \
		uv sync; \
	fi

test:
	PYTHONPATH=. pytest -q

lint:
	ruff check .

fix:
	ruff check . --fix

fmt:
	ruff format .

clean:
	rm -rf .ruff_cache .venv uv.lock

