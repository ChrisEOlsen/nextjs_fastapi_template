from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.db.connections import engine
from alembic.config import Config
from alembic import command
from app.api.v1.endpoints.auth import router as auth_router

# Function to run Alembic migrations
def run_migrations():
    """Run Alembic migrations at server startup."""
    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")

# Init lifespan of FastAPI application
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Server start: Run migrations if you want during development and frequent changes are being made
    # Else use: alembic upgrade head from fastapi/
    # run_migrations()

    yield  # App runs while this context is active

    # Server shutdown: Dispose of the database connection
    await engine.dispose()

# Initialize FastAPI app with lifespan management
app = FastAPI(lifespan=lifespan)

# Include the auth router
app.include_router(auth_router)
