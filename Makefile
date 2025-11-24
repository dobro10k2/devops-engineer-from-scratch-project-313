# Makefile
# Commands to install and run FastAPI app

VENV=venv
PYTHON=python3

.PHONY: install run clean

install:
	# Create virtual environment if it does not exist
	test -d $(VENV) || $(PYTHON) -m venv $(VENV)
	. $(VENV)/bin/activate && pip install --upgrade pip
	. $(VENV)/bin/activate && pip install fastapi uv uvicorn

run:
	. $(VENV)/bin/activate && uv run fastapi dev --host 0.0.0.0 --port 8080

clean:
	rm -rf $(VENV)
