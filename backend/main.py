from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.routers import example_router
from app.database.connections import engine
from alembic.config import Config
from alembic import command

# Function to run Alembic migrations
def run_migrations():
    """Run Alembic migrations at server startup."""
    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")

# Init lifespan of FastAPI application
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Server start: Run migrations if you want during development and frequent changes are being made
    # Else use: alembic upgrade head from backend/
    # run_migrations()

    yield  # App runs while this context is active

    # Server shutdown: Dispose of the database connection
    await engine.dispose()

# Initialize FastAPI app with lifespan management
app = FastAPI(lifespan=lifespan)

# Include the example router
app.include_router(example_router.router)
