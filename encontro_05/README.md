# Encontro 05 - Utilizando Provedor de Nuvem e Deploy de Aplicações

Pessoal, nosso objetivo aqui é compreender como podemos utilizar provedores de nuvem para hospedar nossos clusters Kubernetes e como fazer o deploy de aplicações neles. Vamos focar em dois pontos principais:

- Construir nossa aplicação para ser executada em Kubernetes Local (k3d);
- Colocar nossa aplicação para rodar em um provedor de nuvem (AWS nesse material por enquanto).

## 1. Construindo nossa Aplicação

Vamos tomar por base nossa aplicação vai ser uma API simples com FastAPI que possui 3 endpoints:
- `/health`: Que retorna o status da aplicação;
- `/predict`: Que dado um JSON de entrada, retorna uma predição;
- `/items`: Retorna uma lista de itens (simulando um banco de dados).

Vamos verificar o nosso arquivo `app.py`:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

```