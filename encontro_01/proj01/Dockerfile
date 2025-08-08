# Use uma imagem base oficial do Python
FROM python:3.11-slim

# Defina o diretório de trabalho dentro do container
WORKDIR /app

# Copie os arquivos de requisitos, se existirem
COPY requirements.txt .

# Instale as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copie o restante da aplicação
COPY . .

# Exponha a porta padrão (ajuste conforme necessário)
EXPOSE 8000

# Comando para rodar a aplicação (ajuste conforme seu framework)
CMD ["python", "main.py"]