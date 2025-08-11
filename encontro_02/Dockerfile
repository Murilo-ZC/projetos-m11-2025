# Etapa 1 — build
FROM golang:1.23 AS builder

WORKDIR /app

# Copia (se houver) manifests de módulo
COPY go.* ./

# Se existir go.mod, baixa deps; senão, cria um módulo mínimo
ARG MODULE_PATH=example.com/ping
RUN if [ -f go.mod ]; then \
      go mod download; \
    else \
      go mod init ${MODULE_PATH}; \
      go mod tidy; \
    fi

# Copia o restante do código
COPY . .

# Compila binário estático e enxuto
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -buildvcs=false -ldflags="-s -w" -o /ping .

# Etapa 2 — imagem final Distroless (com CAs, sem shell)
FROM gcr.io/distroless/base-debian12

# roda como não-root
USER nonroot:nonroot

# porta informativa
EXPOSE 8080

# copia só o binário
COPY --from=builder /ping /ping

ENTRYPOINT ["/ping"]