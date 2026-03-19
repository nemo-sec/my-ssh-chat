FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git gcc musl-dev

WORKDIR /app
RUN git clone https://github.com/shazow/ssh-chat.git .

# Baixa as dependências
RUN go mod download

# Tenta compilar buscando o arquivo main.go automaticamente em cmd/ ou na raiz
RUN CGO_ENABLED=0 go build -o /ssh-chat $(find . -name "main.go" | head -n 1)

FROM alpine:latest
RUN apk add --no-cache openssh-keygen ca-certificates
WORKDIR /chat

COPY --from=builder /ssh-chat .
RUN chmod +x ./ssh-chat

# Gera a chave do servidor
RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

# Garantimos que ele use a porta 2222
EXPOSE 2222
CMD ["./ssh-chat", "--bind", "0.0.0.0:2222", "--admin", "id_ed25519"]
