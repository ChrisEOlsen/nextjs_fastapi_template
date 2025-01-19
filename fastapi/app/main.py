from fastapi import FastAPI, Depends, HTTPException
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from app.db.connections import engine
from alembic.config import Config
from fastapi.middleware.cors import CORSMiddleware
from alembic import command
from app.middleware.shared_secret import validate_shared_secret

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

# Add the shared secret middleware - 
# All nextjs routes pointing to fastapi routes need to contain:  
# "X-Shared-Secret": process.env.SHARED_SECRET
# This ensures that only the nextjs application can communicate with fastapi
app.middleware("http")(validate_shared_secret)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Only allow Next.js domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

