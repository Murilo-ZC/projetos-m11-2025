# Use uma imagem oficial do Node.js
FROM node:20-slim

# Defina o diretório de trabalho dentro do container
WORKDIR /app

# Copie os arquivos de dependências primeiro
COPY package*.json ./

# Instale as dependências
RUN npm install

# Copie o restante dos arquivos do projeto
COPY . .

# Exponha a porta usada pelo Express (ajuste se necessário)
EXPOSE 3000

# Comando padrão para rodar o container
CMD ["node", "server.js"]