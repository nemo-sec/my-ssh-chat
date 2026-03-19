FROM golang:1.21-alpine AS builder

# Instala git para clonar o repositório
RUN apk add --no-cache git

# Clona e compila o ssh-chat
RUN git clone https://github.com/shazow/ssh-chat.git /app
WORKDIR /app
RUN go build -o /ssh-chat bin/main.go

# Estágio final (imagem leve)
FROM alpine:latest
RUN apk add --no-cache openssh-keygen

WORKDIR /root/
COPY --from=builder /ssh-chat .

# Gera a chave do servidor necessária para o SSH funcionar
RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

# Usa a variável de ambiente PORT do Koyeb ou 2222 como padrão
ENV PORT=2222

# Comando para rodar o chat
CMD ./ssh-chat --bind 0.0.0.0:${PORT} --admin id_ed25519
