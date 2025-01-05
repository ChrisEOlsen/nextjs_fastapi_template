#!/bin/bash

# Create the backend folder structure
mkdir -p backend/app/{models,routers,schemas,services,templates,utils,database}
touch backend/app/models/__init__.py
touch backend/app/schemas/__init__.py

# Add Base model code to app.models.__init__.py
cat <<EOL >backend/app/models/__init__.py
from sqlalchemy.ext.declarative import declarative_base

# Centralized Base for all models
Base = declarative_base()

# Import all models here so they are registered with Alembic
# For example:
# from app.models.user import User
EOL

# Add database connections.py
cat <<EOL >backend/app/database/connections.py
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Database URL from .env
DATABASE_URL = os.getenv("DATABASE_URL")

# Create Async Engine
engine = create_async_engine(DATABASE_URL, echo=True)

# Session Maker
async_session = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)
EOL

# Add database dependencies.py
cat <<EOL >backend/app/database/dependencies.py
from app.database.connections import async_session

# Dependency for DB session
async def get_db():
    async with async_session() as session:
        yield session
EOL

# Add basic starter code to main.py
cat <<EOL >backend/main.py
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
EOL

# Add example router
mkdir -p backend/app/routers
cat <<EOL >backend/app/routers/example_router.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/example")
async def example_endpoint():
    return {"message": "This is an example endpoint!"}
EOL

# Create the frontend folder structure
mkdir -p frontend/src/{components,pages,styles}

# Add README.md to the frontend
cat <<EOL >frontend/README.md
# Frontend (Next.js)

This folder contains the Next.js application.

- **src/components/**: Reusable React components.
- **src/pages/**: Route-based pages for the application.
- **src/styles/**: Tailwind CSS and other styles.

## Commands
Refer to the 'setup_commands.txt' in the zz_dev_help folder for installation instructions.
EOL

# Add starter code to frontend src/pages/index.js
cat <<EOL >frontend/src/pages/index.js
// Entry point for the Next.js application
export default function Home() {
  return (
    <div>
      <h1>Welcome to the Next.js Frontend</h1>
    </div>
  );
}
EOL

# Add _app.js file to frontend src/pages
cat <<EOL >frontend/src/pages/_app.js
// Import global CSS styles
import '../styles/globals.css';

// Custom App component
export default function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />;
}
EOL

# Add globals.css file to frontend src/styles
cat <<EOL >frontend/src/styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Add Tailwind configuration file
cat <<EOL >frontend/tailwind.config.js
// Tailwind CSS configuration file
module.exports = {
  content: ['./src/pages/**/*.{js,ts,jsx,tsx}', './src/components/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOL

# Add PostCSS configuration file
cat <<EOL >frontend/postcss.config.js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

# Create zz_dev_help folder and add documentation
mkdir -p zz_dev_help

# Add folder_structure_explained.txt
cat <<EOL >zz_dev_help/folder_structure_explained.txt
# Folder Structure Explanation

## Backend
- **app/models/**: SQLAlchemy models for database tables.
- **app/routers/**: FastAPI routers to define API endpoints.
- **app/schemas/**: Pydantic schemas for data validation and serialization.
- **app/services/**: Business logic and reusable backend functionalities.
- **app/templates/**: HTML templates for emails or server-rendered responses.
- **app/utils/**: Helper functions and utilities.
- **app/database/connections.py**: Manages database engine and session creation.
- **app/database/dependencies.py**: Provides dependency injection for DB sessions.
- **main.py**: The entry point for the FastAPI application.

## Frontend
- **src/components/**: Reusable React components.
- **src/pages/**: Route-based pages for the Next.js application.
- **src/styles/**: Tailwind CSS and other styles.

## zz_dev_help
- **folder_structure_explained.txt**: Explains the purpose of each folder and file.
- **setup_commands.txt**: Contains installation commands and instructions.
EOL

# Add setup_commands.txt with detailed setup instructions
cat <<EOL >zz_dev_help/setup_commands.txt
# Installation Commands and Setup Instructions

## Backend
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn pydantic sqlalchemy alembic asyncpg psycopg2-binary python-dotenv

# Initialize Alembic
alembic init alembic

# Update env.py in Alembic folder
# Modify 'target_metadata' to point to app.models.Base
# Update sqlalchemy.url to use DATABASE_URL_SYNC from the .env file

# PostgreSQL Setup
# Start PostgreSQL
brew services start postgresql

# Open PostgreSQL shell
psql postgres

# Create a database and user
CREATE DATABASE my_database;
CREATE USER my_user WITH PASSWORD 'strong_password';
GRANT ALL PRIVILEGES ON DATABASE my_database TO my_user;

# Update .env file
cat <<DOTENV >backend/.env
DATABASE_URL=postgresql+asyncpg://my_user:strong_password@localhost/my_database
DATABASE_URL_SYNC=postgresql+psycopg2://my_user:strong_password@localhost/my_database
DOTENV

## Frontend
# Initialize the project
npm init -y

# Install dependencies
npm install next react react-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init


#Add scripts to package.json:
  "scripts": {
    "dev": "next dev",                  
    "build": "next build",             
    "start": "next start",             
    "lint": "next lint",               
    "test": "echo \"Error: no test specified\" && exit 1", 
    "postinstall": "next build"        
  },

## Running the Project
# Backend: Run the FastAPI server
uvicorn main:app --reload

# Frontend: Start the Next.js development server
npm run dev
EOL

echo "Project structure created successfully with Tailwind, _app.js, and globals.css included!"
