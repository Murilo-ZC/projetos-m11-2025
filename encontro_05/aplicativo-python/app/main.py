from helper import get_random_http_status
from fastapi import FastAPI, Response
from fastapi.responses import JSONResponse
from typing import Optional

app = FastAPI()

@app.get("/random-status")
def random_status(response : Response):
    result = get_random_http_status()
    response.status_code = result["status_code"]
    return result