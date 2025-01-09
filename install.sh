#!/bin/bash

# Select OS Type
echo "What OS is this?"
echo "1. macOS"
echo "2. Linux"
read -p "Answer: " OS_OPTION

# Check for PostgreSQL installation
if [ "$OS_OPTION" == "1" ]; then
  echo "Installing PostgreSQL using Homebrew..."
  brew install postgresql
  brew services start postgresql
elif [ "$OS_OPTION" == "2" ]; then
  echo "Installing PostgreSQL using APT..."
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib
  sudo service postgresql start
else
  echo "Invalid selection. Exiting."
  exit 1
fi

# Frontend Setup
echo "Setting up the frontend environment..."
cd nextjs || exit
npm init -y
npm install next react react-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init
echo "Frontend setup complete. Returning to root directory..."
cd ..

# Backend Setup
echo "Setting up the backend environment..."
cd fastapi || exit
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn pydantic sqlalchemy alembic asyncpg psycopg2-binary python-dotenv greenlet
echo "Backend dependencies installed."

# Initialize Alembic
if [ ! -f "alembic.ini" ]; then
  echo "Initializing Alembic..."
  alembic init migrations
  mv migrations app/db/

  # Update alembic.ini to point to the correct script location
  sed -i '' 's/^script_location = migrations/script_location = app\/db\/migrations/' alembic.ini 2>/dev/null ||
    sed -i 's/^script_location = migrations/script_location = app\/db\/migrations/' alembic.ini
fi

cd ..

# PostgreSQL Database Setup
echo "Would you like to set up a PostgreSQL database? (yes/no)"
read SETUP_DB

if [ "$SETUP_DB" == "yes" ]; then
  echo "Do you want to use an existing PostgreSQL user or create a new one?"
  echo "1. Use an existing user"
  echo "2. Create a new user"
  read USER_OPTION

  if [ "$USER_OPTION" == "2" ]; then
    echo "Enter a username for the new PostgreSQL user:"
    read PG_USER
    echo "Enter a password for the new PostgreSQL user:"
    read -s PG_PASSWORD

    if [ "$OS_OPTION" == "1" ]; then
      psql postgres -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';" || echo "Error creating user"
    elif [ "$OS_OPTION" == "2" ]; then
      sudo -u postgres psql -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';" || echo "Error creating user"
    fi
  elif [ "$USER_OPTION" == "1" ]; then
    echo "Enter the existing PostgreSQL username:"
    read PG_USER
    echo "Enter the password for the PostgreSQL user:"
    read -s PG_PASSWORD
  else
    echo "Invalid selection. Exiting."
    exit 1
  fi

  echo "Enter a name for the new database:"
  read PG_DB

  if [ "$OS_OPTION" == "1" ]; then
    psql postgres -c "CREATE DATABASE $PG_DB;" || echo "Error creating database"
    psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_DB TO $PG_USER;" || echo "Error granting privileges"
  elif [ "$OS_OPTION" == "2" ]; then
    sudo -u postgres psql -c "CREATE DATABASE $PG_DB;" || echo "Error creating database"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PG_DB TO $PG_USER;" || echo "Error granting privileges"
  fi

  # Create .env file in the fastapi-backend folder
  echo "Creating .env file in the fastapi-backend folder..."
  ENV_FILE="fastapi/.env"

  # Write database URLs to .env
  echo "DATABASE_URL=postgresql+asyncpg://$PG_USER:$PG_PASSWORD@localhost/$PG_DB" >$ENV_FILE
  echo "DATABASE_URL_SYNC=postgresql+psycopg2://$PG_USER:$PG_PASSWORD@localhost/$PG_DB" >>$ENV_FILE

  echo ".env file created with the following content:"
  cat $ENV_FILE

  # Output env.py update instructions
  echo "Make sure to update the 'env.py' in your Alembic folder as follows:"
  echo "--------------------------------"
  echo "import os"
  echo "from dotenv import load_dotenv"
  echo
  echo "# Load environment variables from .env"
  echo "load_dotenv()"
  echo
  echo "# Import Base from your models folder"
  echo "from app.db.models import Base"
  echo
  echo "target_metadata = Base.metadata"
  echo "--------------------------------"
else
  echo "Skipping PostgreSQL setup..."
fi

# Output instructions for modifying package.json
echo "Add the following scripts to the 'scripts' section of your package.json file:"
echo "
  \"scripts\": {
    \"dev\": \"next dev\",
    \"build\": \"next build\",
    \"start\": \"next start\",
    \"lint\": \"next lint\",
    \"test\": \"echo \\\"Error: no test specified\\\" && exit 1\",
    \"postinstall\": \"next build\"
  }
"

# Final instructions
echo "Development environment setup complete!"
