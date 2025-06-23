como armar el jeunkins en proyecto

primero clonar este repositorio

levantarlo con docker compose up --build

entrar al contenedor con docker exec -it jenkins bash

coloca este comando groupadd docker

luego este comando usermod -aG docker jenkins

estos comandos le daran permisos a jenkins para usar docker

para confirmar si todo va bien. usa este comando groups jenkins

si sale jenkins : jenkins docker, estas en buen camino

luego en el proyecto que controlara jenkins, crea un jenkins en la raiz del proyecto

colocale esto:

pipeline {
agent any
stages {
stage('Build and Deploy') {
steps {
echo 'Deteniendo servicios actuales...'
sh 'cd /var/jenkins_home/workspace/evento-petrolero-info && docker compose down'

                echo 'Obteniendo últimas actualizaciones...'
                sh 'cd /var/jenkins_home/workspace/evento-petrolero-info && git pull origin master'

                echo 'Construyendo y levantando contenedores...'
                sh 'cd /var/jenkins_home/workspace/evento-petrolero-info && docker compose up --build -d'
            }
        }
    }

}

entra a la web de jenkins, revisa la consola del su docker compose, ahi saldra una contraseña que necesitaras para instalar jenkins

porfavor, crea un usuario con contraseña que recuerdes, no uses la que viene por defecto (esa larga)

en el panel vas a donde dice create an item o algo asi

colocas el nombre del proyecto (mejor si es del repo que se usara) y seleccionas en pipeline

presionas a la izquierda en la opcion de Pipeline

aqui sigue esto:

En Triggers:

Selecciona: GitHub hook trigger for GITScm polling

En Pipeline:

Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/<tu-repo>
Branch: \*/master (o la rama que uses)
Script Path: Jenkinsfile

AUN NO LE DES SAVE

vas a l github del repo, vas a settinge, a webhooks, a add a webhook

coloca esto:

Payload URL:http://<tu-ip>:8080/github-webhook/
Content type:application/json
Events:Just the push event

lo guardas

AHI RECIEN LE DAS A SAVE EN JENKINS

en el panel de jenkins le presionas a "contruir ahora"

este tutorial esta en un primera fase, en el futuro colocare imagenes
