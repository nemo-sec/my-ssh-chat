FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/shazow/ssh-chat.git .

RUN go mod download
# Compila o binário no caminho correto
RUN go build -o /ssh-chat ./cmd/ssh-chat/main.go || go build -o /ssh-chat .

FROM alpine:latest
RUN apk add --no-cache openssh-keygen

WORKDIR /root/
COPY --from=builder /ssh-chat .

# --- ESTA É A LINHA QUE RESOLVE O ERRO ---
RUN chmod +x /root/ssh-chat

RUN ssh-keygen -t ed25519 -f id_ed25519 -N ""

ENV PORT=2222

# Usamos o caminho absoluto para não ter erro de diretório
CMD ["/root/ssh-chat", "--bind", "0.0.0.0:2222", "--admin", "id_ed25519"]
