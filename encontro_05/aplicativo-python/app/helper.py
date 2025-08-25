from random import choice
from typing import Optional
from helper_constants import STATUS_CODE

# Função que retorna um status aleatório
def get_random_http_status(status: Optional[int] = None) -> dict:
    if status is not None:
        # Se um status específico foi solicitado
        if status in STATUS_CODE:
            status_code = status
            code = STATUS_CODE[status]
        else:
            # Status solicitado não existe
            status_code = None
            code = "Unknown Status Code"
    else:
        # Status aleatório
        status_code = choice(list(STATUS_CODE.keys()))
        code = STATUS_CODE[status_code]
    
    return {"status_code": status_code, "code": code}
