FROM golang:1.21-bullseye AS builder

# Instala git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/shazow/ssh-chat.git .

# Compilação padrão para Linux 64-bit
RUN go mod download
RUN go build -o /ssh-chat ./cmd/ssh-chat/main.go || go build -o /ssh-chat .

# Imagem final usando Debian Slim (muito mais compatível que Alpine)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y openssh-client ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /chat
COPY --from=builder /ssh-chat .
RUN chmod +x ./ssh-chat

# Gera a chave de host
RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

# Porta padrão
ENV PORT=2222
EXPOSE 2222

# Comando de inicialização
CMD ["./ssh-chat", "--bind", "0.0.0.0:2222", "--admin", "id_ed25519"]
