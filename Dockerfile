FROM shazow/ssh-chat

# O ssh-chat usa a porta 2022 por padrão
EXPOSE 2022

# Comando para iniciar gerando as chaves automaticamente
ENTRYPOINT ["/ssh-chat", "--address", "0.0.0.0:2022", "--verbosity=debug"]
