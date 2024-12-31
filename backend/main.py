# Entry point for the FastAPI application
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI Backend"}
