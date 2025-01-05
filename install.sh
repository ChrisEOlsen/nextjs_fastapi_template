#!/bin/bash

echo "Is this script being run on MacOS or Linux? (Enter macos or linux)"
read OS_TYPE

# Check for PostgreSQL installation
if [ "$OS_TYPE" == "macos" ]; then
  echo "Installing PostgreSQL using Homebrew..."
  brew install postgresql
  brew services start postgresql
elif [ "$OS_TYPE" == "linux" ]; then
  echo "Installing PostgreSQL using APT..."
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib
  sudo service postgresql start
else
  echo "Invalid OS type entered. Exiting."
  exit 1
fi

# Frontend Setup
echo "Setting up the frontend environment..."
cd frontend || exit
npm init -y
npm install next react react-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

echo "Frontend setup complete. Returning to root directory..."
cd ..

# Backend Setup
echo "Setting up the backend environment..."
cd backend || exit
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn pydantic sqlalchemy alembic asyncpg psycopg2-binary python-dotenv greenlet
pip freeze >requirements.txt

# Initialize Alembic in the backend folder
echo "Initializing Alembic..."
alembic init alembic

# Update Alembic configuration paths
echo "Updating Alembic paths..."
sed -i '' 's|script_location = alembic|script_location = backend/alembic|' alembic.ini 2>/dev/null ||
  sed -i 's|script_location = alembic|script_location = backend/alembic|' alembic.ini

# Return to the root directory
cd ..

echo "Would you like to set up a PostgreSQL database? (yes/no)"
read SETUP_DB

if [ "$SETUP_DB" == "yes" ]; then
  echo "Do you want to use an existing PostgreSQL user or create a new one? (Enter existing or new)"
  read USER_OPTION

  if [ "$USER_OPTION" == "new" ]; then
    echo "Enter a username for the new PostgreSQL user:"
    read PG_USER
    echo "Enter a password for the new PostgreSQL user:"
    read -s PG_PASSWORD

    if [ "$OS_TYPE" == "macos" ]; then
      psql postgres -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';"
    elif [ "$OS_TYPE" == "linux" ]; then
      sudo -u postgres psql -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';"
    fi
  elif [ "$USER_OPTION" == "existing" ]; then
    echo "Enter the existing PostgreSQL username:"
    read PG_USER
    echo "Enter the password for the PostgreSQL user:"
    read -s PG_PASSWORD
  else
    echo "Invalid user option entered. Exiting."
    exit 1
  fi

  echo "Enter a name for the new database:"
  read PG_DB

  if [ "$OS_TYPE" == "macos" ]; then
    psql postgres -c "CREATE DATABASE $PG_DB;"
    psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_DB TO $PG_USER;"
  elif [ "$OS_TYPE" == "linux" ]; then
    sudo -u postgres psql -c "CREATE DATABASE $PG_DB;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PG_DB TO $PG_USER;"
  fi

  # Output instructions for .env file
  echo "Add the following to your backend/.env file:"
  echo "DATABASE_URL=postgresql+asyncpg://$PG_USER:$PG_PASSWORD@localhost/$PG_DB"
  echo "DATABASE_URL_SYNC=postgresql+psycopg2://$PG_USER:$PG_PASSWORD@localhost/$PG_DB"
  echo "Make sure to update the 'env.py' in your Alembic folder to use the DATABASE_URL_SYNC variable."
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
echo "COMPLETE"
