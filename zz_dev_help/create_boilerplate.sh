#!/bin/bash

# Create frontend folder and structure
mkdir -p frontend/src/{components,pages,styles}
cat <<EOL >frontend/README.md
# Frontend (Next.js)

This folder contains the Next.js application.

- **src/components/**: Reusable React components.
- **src/pages/**: Route-based pages for the application.
- **src/styles/**: Tailwind CSS and other global styles.

## Setup Commands
Refer to the 'setup_commands.txt' for installation instructions.
EOL

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

cat <<EOL >frontend/postcss.config.js
// PostCSS configuration file
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

touch frontend/package.json

# Create backend folder and structure
mkdir -p backend/app/{models,schemas,routers,services,utils,templates}
cat <<EOL >backend/main.py
# Entry point for the FastAPI application
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI Backend"}
EOL

cat <<EOL >backend/app/models/__init__.py
# SQLAlchemy models for PostgreSQL
# Example:
# from sqlalchemy import Column, Integer, String
# from app.database import Base
#
# class User(Base):
#     __tablename__ = "users"
#     id = Column(Integer, primary_key=True, index=True)
#     name = Column(String, index=True)
EOL

cat <<EOL >backend/app/schemas/__init__.py
# Pydantic schemas for input/output validation
# Example:
# from pydantic import BaseModel
#
# class User(BaseModel):
#     id: int
#     name: str
#
#     class Config:
#         orm_mode = True
EOL

cat <<EOL >backend/requirements.txt
# FastAPI and SQLAlchemy dependencies
fastapi
sqlalchemy
pydantic
uvicorn[standard]
EOL

# Create Docker and NGINX setup
mkdir -p docker/nginx
cat <<EOL >docker/Dockerfile
# Dockerfile for the application
# Use a base image for the backend, e.g., Python
FROM python:3.10-slim

# Add your installation and application setup commands here
# Example:
# COPY ./backend /app
# WORKDIR /app
# RUN pip install -r requirements.txt
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOL

cat <<EOL >docker/docker-compose.yml
# Docker Compose configuration for frontend, backend, and PostgreSQL
version: '3.8'
services:
  backend:
    build:
      context: ../backend
      dockerfile: ../docker/Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - ../backend:/app
    depends_on:
      - db
  frontend:
    build:
      context: ../frontend
    ports:
      - "3000:3000"
    volumes:
      - ../frontend:/app
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: your_user
      POSTGRES_PASSWORD: your_password
      POSTGRES_DB: your_database
    ports:
      - "5432:5432"
EOL

cat <<EOL >docker/nginx/nginx.conf
# NGINX configuration for reverse proxy
# Replace with specific server block settings as needed
server {
  listen 80;

  location / {
    proxy_pass http://frontend:3000;
  }

  location /api/ {
    proxy_pass http://backend:8000;
  }
}
EOL

# Create documentation files
cat <<EOL >folder_structure_explained.txt
# Folder Structure Explanation

## Frontend
- **src/components/**: Reusable React components.
- **src/pages/**: Route-based pages for the application.
- **src/styles/**: Tailwind CSS and other styles.

## Backend
- **app/models/**: SQLAlchemy models for defining database tables.
- **app/schemas/**: Pydantic schemas for data validation.
- **app/routers/**: API route handlers.
- **app/services/**: Business logic and reusable functionalities.
- **app/utils/**: Helper functions and utilities.
- **app/templates/**: HTML templates for emails or server-rendered content.

## Docker
- **Dockerfile**: Builds application containers.
- **docker-compose.yml**: Orchestrates services (frontend, backend, database).
- **nginx/nginx.conf**: Configuration for NGINX as a reverse proxy.

## Shared Documentation
- **setup_commands.txt**: Contains installation commands.
- **folder_structure_explained.txt**: Explains folder and file purposes.
EOL

cat <<EOL >setup_commands.txt
# Installation Commands

# Frontend
npm install next react react-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

# Backend
pip install fastapi uvicorn sqlalchemy pydantic

# Docker
# Ensure Docker and Docker Compose are installed on your system.
EOL

echo "Boilerplate created successfully!"
