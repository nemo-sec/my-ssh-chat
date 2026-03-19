FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
RUN git clone https://github.com/shazow/ssh-chat.git /app
WORKDIR /app
RUN go build -o ssh-chat bin/main.go

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/ssh-chat .
# Gera a chave do servidor para o SSH funcionar
RUN apk add --no-cache openssh-keygen && \
    ssh-keygen -t ed25519 -f id_ed25519 -N ""

# O Koyeb passa a porta pela variável $PORT, vamos usá-la
CMD ./ssh-chat --bind 0.0.0.0:${PORT} --admin id_ed25519
