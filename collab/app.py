import uuid
from typing import Union, List
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from collab.dynamo import create_document
from fastapi.encoders import jsonable_encoder
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


@app.post("/share")
def share(emails: List[str]):
    print(emails)
    pass


class CreatePayload(BaseModel):
    email: str
    shared_with: list[str]
    text_content: str


@app.post("/create")
def create(payload: CreatePayload):
    print("Here!")
    uid = uuid.uuid4()
    emails = ",".join(
        set(map(lambda x: x.strip(), [payload.email, *payload.shared_with]))
    )
    create_document(str(uid), emails, payload.text_content)
    return JSONResponse(content=jsonable_encoder({"uuid": uid}))


handler = Mangum(app, lifespan="off")
