from typing import Union
import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from mangum import Mangum

# Define static origins
static_origins = [
    "*",
    "http://localhost:5173",
]


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=static_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/greet")
def greet():
    return {"foo": "bar"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


handler = Mangum(app, lifespan="off")
