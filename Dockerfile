# Estágio 1: Baixar o binário oficial
FROM shazow/ssh-chat AS binary

# Estágio 2: Sistema final
FROM debian:bullseye-slim

# Instalar dependências básicas
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Copiar o executável do chat
COPY --from=binary /ssh-chat /ssh-chat

# Criar um script para rodar o chat e um mini-servidor HTTP ao mesmo tempo
RUN echo '#!/bin/bash\n\
python3 -m http.server 8080 & \n\
/ssh-chat --address 0.0.0.0:2022 --verbosity=debug' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expor as duas portas
EXPOSE 2022
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
