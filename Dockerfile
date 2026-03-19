FROM golang:1.21-alpine AS builder

# Instala git e dependências de build
RUN apk add --no-cache git

# Clona o repositório
WORKDIR /app
RUN git clone https://github.com/shazow/ssh-chat.git .

# Baixa as dependências do Go e compila o binário
RUN go mod download
RUN go build -o /ssh-chat ./cmd/ssh-chat/main.go || go build -o /ssh-chat .

# Estágio final (imagem leve)
FROM alpine:latest
RUN apk add --no-cache openssh-keygen

WORKDIR /root/
COPY --from=builder /ssh-chat .

# Gera a chave do servidor
RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

# Usa a porta do Koyeb
ENV PORT=2222

# Comando para rodar
CMD ./ssh-chat --bind 0.0.0.0:${PORT} --admin id_ed25519
