
# Estágio de build
FROM node:20-slim AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Estágio final usando imagem distroless
FROM gcr.io/distroless/nodejs20-debian11

WORKDIR /app
COPY --from=build /app ./dist
COPY --from=build /app/package*.json ./

EXPOSE 3000

CMD ["node", "dist/server.js"]
