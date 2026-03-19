# Usar uma imagem base leve do Debian
FROM debian:bullseye-slim

# Instalar dependências necessárias: curl para baixar o chat e python3 para o health check
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Baixar o binário do ssh-chat diretamente do GitHub (Versão Linux 64-bit)
RUN curl -L https://github.com/shazow/ssh-chat/releases/download/v1.10/ssh-chat-linux_amd64.tgz | tar xvz \
    && mv /ssh-chat/ssh-chat /usr/local/bin/ssh-chat \
    && chmod +x /usr/local/bin/ssh-chat

# Criar o script de inicialização dupla
RUN echo '#!/bin/bash\n\
echo "Iniciando servidor de rotas na porta 8080..." \n\
python3 -m http.server 8080 & \n\
echo "Iniciando SSH-Chat na porta 2022..." \n\
ssh-chat --address 0.0.0.0:2022 --verbosity=debug' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Expor as portas necessárias
EXPOSE 8080
EXPOSE 2022

ENTRYPOINT ["/entrypoint.sh"]
