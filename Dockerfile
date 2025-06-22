FROM jenkins/jenkins:lts-jdk17

# Cambiamos al usuario root para poder instalar paquetes
USER root

# Actualizamos e instalamos herramientas básicas
RUN apt update && \
    apt install -y curl sudo libffi-dev jq

# Creamos la carpeta donde se guardará el plugin de Docker Compose V2
RUN mkdir -p /usr/lib/docker/cli-plugins

# Descargamos Docker Compose V2 y lo colocamos en la carpeta correcta
RUN curl -SL https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64  \
        -o /usr/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/lib/docker/cli-plugins/docker-compose

# Opcional: Verificar que el plugin esté bien instalado
RUN ls -la /usr/lib/docker/cli-plugins/

# Volvemos al usuario Jenkins
USER jenkins