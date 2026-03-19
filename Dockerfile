FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git gcc musl-dev

WORKDIR /app
RUN git clone https://github.com/shazow/ssh-chat.git .

# Compilação estática para garantir que rode em qualquer Linux
RUN go mod download
RUN CGO_ENABLED=0 go build -o /ssh-chat ./cmd/ssh-chat/main.go

FROM alpine:latest
# Instala o básico e cria um diretório limpo
RUN apk add --no-cache openssh-keygen ca-certificates
WORKDIR /chat

# Copia o binário do builder
COPY --from=builder /ssh-chat .
RUN chmod +x ./ssh-chat

# Gera a chave de admin no diretório atual
RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

# Expõe a porta que o Koyeb vai usar
ENV PORT=2222
EXPOSE 2222

# Comando usando caminho relativo garantido
CMD ["./ssh-chat", "--bind", "0.0.0.0:2222", "--admin", "id_ed25519"]
