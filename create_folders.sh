#!/bin/bash

# Create the backend folder structure
mkdir -p backend/app/{models,routers,schemas,services,templates,utils}
touch backend/app/models/__init__.py
touch backend/app/schemas/__init__.py

# Add basic starter code to main.py
cat <<EOL >backend/main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.routers import example_router

# Init lifespan of FastAPI application
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Server start stuff
    yield
    # Server close stuff 

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

# Add Tailwind configuration file
cat <<EOL >frontend/tailwind.config.js
// Tailwind CSS configuration file
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
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
- **main.py**: The entry point for the FastAPI application.

## Frontend
- **src/components/**: Reusable React components.
- **src/pages/**: Route-based pages for the Next.js application.
- **src/styles/**: Tailwind CSS and other styles.

## zz_dev_help
- **folder_structure_explained.txt**: Explains the purpose of each folder and file.
- **setup_commands.txt**: Contains installation commands and instructions.
EOL

# Add setup_commands.txt
cat <<EOL >zz_dev_help/setup_commands.txt
# Installation Commands and Setup Instructions

## Backend
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn pydantic sqlalchemy

## Frontend
# Initialize the project
npm init -y

# Install dependencies
npm install next react react-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

## Running the Project
# Backend: Run the FastAPI server
uvicorn main:app --reload

# Frontend: Start the Next.js development server
npm run dev
EOL

echo "Project structure created successfully!"
