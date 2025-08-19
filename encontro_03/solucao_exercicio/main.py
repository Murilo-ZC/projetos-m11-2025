from fastapi import FastAPI
import uvicorn

app = FastAPI()


@app.get("/calc/")
async def calc(op1: float = 0, op2: float = 0, op : str = ''):
    if not op:
        return {"result":"Deu Ruim"}    
    op = op.lower()
    if op == 'soma':
            return {"result":f"{op1+op2}"} 
    elif op =='subtracao':
            return {"result":f"{op1-op2}"}
    elif op =='multiplicacao':
            return {"result":f"{op1*op2}"}
    elif op =='divisao':
            return {"result":f"{op1/op2}"}
    else:
            return {"result":"Nicola"}
        
if __name__=="__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False, debug=False)