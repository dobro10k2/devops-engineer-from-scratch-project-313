.PHONY: install run test lint fmt clean

install:
	uv sync

run:
	uv run uvicorn app.main:app --host 0.0.0.0 --port 8080

test:
	PYTHONPATH=. uv run pytest -q

lint:
	uv run ruff check .

fmt:
	uv run ruff format .

clean:
	rm -rf .ruff_cache uv.lock test.db

