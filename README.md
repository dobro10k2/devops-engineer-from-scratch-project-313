### Hexlet tests and linter status:
![CI](https://github.com/dobro10k2/devops-engineer-from-scratch-project-313/actions/workflows/ci.yml/badge.svg)
[![Actions Status](https://github.com/dobro10k2/devops-engineer-from-scratch-project-313/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/devops-engineer-from-scratch-project-313/actions)

### Deployed app
[FastAPI Project on Render](https://dobro10k2.onrender.com)

### Sentry
Errors are tracked via Sentry using the `SENTRY_DSN` environment variable.

# Deploy applications on PaaS

This project is a simple FastAPI application with a frontend served via Caddy.

## How to run locally

```bash
make install   # Install dependencies via uv
make run       # Run FastAPI on port 8080
make dev       # Run backend + frontend together
make test      # Run tests
make lint      # Check code with Ruff
make fix       # Auto-fix issues with Ruff
make fmt       # Format code with Ruff
make clean     # Clean uv/Ruff cache

