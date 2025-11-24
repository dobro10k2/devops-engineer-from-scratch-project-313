# app/main.py
# Entry point for FastAPI application with Sentry integration

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sentry_sdk
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware

# Get Sentry DSN from environment
SENTRY_DSN = os.getenv("SENTRY_DSN")

# Initialize FastAPI
fastapi_app = FastAPI(title="DevOps Engineer Project 313")

# Add CORS middleware before Sentry
fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@fastapi_app.get("/ping")
async def ping():
    return "pong"

# Test route to trigger Sentry error
@fastapi_app.get("/sentry-debug")
async def trigger_error():
    1 / 0  # This will send an error to Sentry

# Wrap app in Sentry middleware only if DSN is set
if SENTRY_DSN:
    app = SentryAsgiMiddleware(fastapi_app)
else:
    app = fastapi_app

