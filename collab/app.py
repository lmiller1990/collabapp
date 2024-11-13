import uuid
from typing import Union, List
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from collab.dynamo import create_document, fetch_document_by_id
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


@app.get("/greet")
def greet():
    return {"foo": "bar"}


@app.post("/share")
def share(emails: List[str]):
    pass


class CreatePayload(BaseModel):
    email: str
    shared_with: list[str]
    text: str


@app.get("/app")
def index():
    _, index_html = fetch_document_by_id("lachlan-collab-dev", "index.html")
    return HTMLResponse(index_html)


@app.post("/create")
def create(payload: CreatePayload):
    print("Here!")
    uid = uuid.uuid4()
    emails = ",".join(
        set(map(lambda x: x.strip(), [payload.email, *payload.shared_with]))
    )
    create_document(str(uid), emails, payload.text)
    return JSONResponse(content=jsonable_encoder({"uuid": uid}))


@app.get("/documents/{doc_id}")
def get_document(doc_id: str):
    row, doc = fetch_document_by_id("lachlan-collab-documents-dev", doc_id)
    print(row, doc)
    return JSONResponse(content=jsonable_encoder({"doc": doc}))


handler = Mangum(app, lifespan="off")
