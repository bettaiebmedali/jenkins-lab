
pipeline {
    agent any

    environment {
        DOCKER_USER  = 'dockerid'
        DOCKER_IMAGE = 'dockerid/microapp'

        APP_NAME    = ''
        APP_PORT    = ''
        APP_VERSION = ''
    }

    stages {
        stage('Charger .env') {
            steps {
                script {
                    if (!fileExists('.env')) {
                        error('Le fichier .env est absent du workspace.')
                    }

                    def config = [:]

                    readFile('.env').split('\n').each { line ->
                        line = line.trim()

                        if (line && !line.startsWith('#')) {
                            def parts = line.split('=', 2)

                            if (parts.length == 2) {
                                config[parts[0].trim()] =
                                    parts[1].trim()
                            }
                        }
                    }

                    env.APP_NAME =
                        (config['APP_NAME'] ?: '').toLowerCase()
                    env.APP_PORT = config['APP_PORT'] ?: ''
                    env.APP_VERSION = config['APP_VERSION'] ?: ''

                    if (!env.APP_NAME ||
                        !env.APP_PORT ||
                        !env.APP_VERSION) {
                        error('APP_NAME, APP_PORT et APP_VERSION sont obligatoires.')
                    }

                    if (!(env.APP_PORT ==~ /[0-9]+/) ||
                        env.APP_PORT.toInteger() < 1 ||
                        env.APP_PORT.toInteger() > 65535) {
                        error('APP_PORT doit être compris entre 1 et 65535.')
                    }

                    if (!(env.APP_VERSION ==~
                        /[0-9]+\.[0-9]+\.[0-9]+/)) {
                        error('APP_VERSION doit respecter le format X.Y.Z.')
                    }

                    echo "Application : ${env.APP_NAME}"
                    echo "Port        : ${env.APP_PORT}"
                    echo "Version     : ${env.APP_VERSION}"
                    echo "Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}"
                }
            }
        }

        stage('Build Docker') {
            steps {
                echo 'Construction de l’image Docker...'

                sh '''
                    set -eu
                    docker build \
                      -t "$DOCKER_IMAGE:$APP_VERSION" \
                      -t "$DOCKER_IMAGE:latest" \
                      .
                    docker images "$DOCKER_IMAGE"
                '''
            }
        }

        stage('Login Docker Hub') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([
                    string(
                        credentialsId: 'DOCKER_PASSWORD',
                        variable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DOCKER_PASSWORD" |
                          docker login \
                            --username "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    set -eu
                    docker push "$DOCKER_IMAGE:$APP_VERSION"
                    docker push "$DOCKER_IMAGE:latest"
                '''
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo """
                ========================================
                DEPLOIEMENT SIMULE
                Application : ${env.APP_NAME}
                Version     : ${env.APP_VERSION}
                Port        : ${env.APP_PORT}
                Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}
                ========================================
                """

                sh '''
                    echo "Déploiement en cours..."
                    sleep 3
                    echo "Déploiement simulé terminé."
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline réussie : ${env.DOCKER_IMAGE}:${env.APP_VERSION}"
        }

        failure {
            echo "Pipeline en échec. Vérifie les logs des étapes."
        }

        always {
            echo 'Fin du pipeline.'
        }
    }
}
