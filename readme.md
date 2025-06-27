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

instrucciones para el uso de variables de entorno:

en jenkins vas "Administrar Jenkins", luego a "Credentials"

haces click en System y luego en Global credentials (unrestricted)

haces click en Add Credentials y colocas de esta manera:

kind:Secret text
Secret:<tu-credenciales>
ID: <el-nombre-de-la-credenciales>
Description: (Opcional)

esto se repetira con cada variable de entorno que necesites

luego en el archivo de jenkinsfile, usa este pipeline

pipeline {
agent any
environment {
(Aqui colocaras las variables de entorno que necesites, ejemplo:
EJEMPLO_1 = credentials('ejemplo-1')
EJEMPLO_2 = credentials('ejemplo-2')
\*ojo, lo que se coloca en credentials debio haber sido colocado en jenkins
)
}
stages {
stage('Preparar entorno') {
steps {
echo '🔹 STAGE 1: Deteniendo contenedores anteriores y limpiando'
sh '''
cd /var/jenkins_home/workspace/(nombre del proyecto)
docker compose down || echo "No había contenedores corriendo"
'''
}
}

        stage('Obtener código') {
            steps {
                echo '🔹 STAGE 2: Obteniendo última versión del código'
                sh '''
                cd /var/jenkins_home/workspace/(nombre del proyecto)
                git pull origin master
                echo "✅ Código actualizado"
                '''
            }
        }

        stage('Construir imagen') {
            steps {
                echo '🔹 STAGE 3: Construyendo imagen Docker con variables de entorno'
                sh '''
                cd /var/jenkins_home/workspace/(nombre del proyecto)
                docker compose build --no-cache \

                (Aqui se colocan las variables de entorno que se obtuvieron en el paso anterior. Ejm:
                --build-arg EJEMPLO_1=${EJEMPLO_1} \
                --build-arg EJEMPLO_2=${EJEMPLO_2}
                )
                echo "✅ Imagen construida exitosamente"
                '''
            }
        }

        stage('Desplegar') {
            steps {
                echo '🔹 STAGE 4: Iniciando contenedores'
                sh '''
                cd /var/jenkins_home/workspace/(nombre del proyecto)
                docker compose up -d
                echo "🚀 Aplicación desplegada en http://<tu-servidor>:3002"
                '''
            }
        }

        stage('Verificación') {
            steps {
                echo '🔹 STAGE 5: Comprobando estado del contenedor'
                sh '''
                cd /var/jenkins_home/workspace/(nombre del proyecto)
                docker ps --filter "name=app" --format "{{.Status}}"
                '''
                echo "✔️ Pipeline completado"
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline fallido - Revisar logs'
            slackSend channel: '#alertas', message: "Falló el deploy de evento-petrolero-admin: ${BUILD_URL}"
        }
        success {
            echo '🎉 ¡Despliegue exitoso!'
        }
    }

}
