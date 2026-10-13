
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

        // ==========================================
        // 1. Charger et valider le fichier .env
        // ==========================================
        stage('Charger .env') {
            steps {
                script {
                    if (!fileExists('.env')) {
                        error('ERREUR : fichier .env absent du workspace.')
                    }

                    def config = [:]

                    readFile('.env').readLines().each { line ->
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

                    if (!env.APP_PORT.isInteger() ||
                        env.APP_PORT.toInteger() < 1 ||
                        env.APP_PORT.toInteger() > 65535) {
                        error('APP_PORT doit être compris entre 1 et 65535.')
                    }

                    def versionParts = env.APP_VERSION.tokenize('.')

                    if (versionParts.size() != 3 ||
                        !versionParts.every { part -> part.isInteger() }) {
                        error('APP_VERSION doit respecter le format X.Y.Z.')
                    }

                    echo '========================================'
                    echo 'Configuration de l’application'
                    echo '========================================'
                    echo "Application : ${env.APP_NAME}"
                    echo "Port        : ${env.APP_PORT}"
                    echo "Version     : ${env.APP_VERSION}"
                    echo "Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}"
                    echo '========================================'
                }
            }
        }

        // ==========================================
        // 2. Vérifier Docker
        // ==========================================
        stage('Vérifier Docker') {
            steps {
                sh '''
                    set -eu
                    docker version
                    docker info
                '''
            }
        }

        // ==========================================
        // 3. Construire l'image Docker
        // ==========================================
        stage('Build Docker') {
            steps {
                echo 'Construction de l’image Docker...'

                sh '''
                    set -eu

                    docker build \
                      --build-arg APP_NAME="$APP_NAME" \
                      --build-arg APP_PORT="$APP_PORT" \
                      --build-arg APP_VERSION="$APP_VERSION" \
                      -t "$DOCKER_IMAGE:$APP_VERSION" \
                      -t "$DOCKER_IMAGE:latest" \
                      .

                    docker images "$DOCKER_IMAGE"
                '''

                echo 'Image Docker construite.'
            }
        }

        // ==========================================
        // 4. Connexion Docker Hub : main uniquement
        // ==========================================
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

                echo 'Connexion Docker Hub effectuée.'
            }
        }

        // ==========================================
        // 5. Publier les images : main uniquement
        // ==========================================
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

                echo 'Images publiées sur Docker Hub.'
            }
        }

        // ==========================================
        // 6. Déploiement simulé : main uniquement
        // ==========================================
        stage('Deploy') {
            when {
                branch 'main'
            }

            steps {
                echo """
                ========================================
                DEPLOIEMENT SIMULE
                ========================================
                Application : ${env.APP_NAME}
                Version     : ${env.APP_VERSION}
                Port        : ${env.APP_PORT}
                Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}
                ========================================
                """

                sh '''
                    set -eu
                    echo "Déploiement en cours..."
                    sleep 3
                    echo "Déploiement simulé terminé."
                '''
            }
        }
    }

    // ==========================================
    // 7. Actions finales
    // ==========================================
    post {
        success {
            echo """
            ========================================
            PIPELINE REUSSIE
            Application : ${env.APP_NAME}
            Version     : ${env.APP_VERSION}
            Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}
            ========================================
            """
        }

        failure {
            echo """
            ========================================
            PIPELINE EN ECHEC
            Application : ${env.APP_NAME ?: 'inconnue'}
            Version     : ${env.APP_VERSION ?: 'inconnue'}
            Consulte les logs des étapes précédentes.
            ========================================
            """
        }

        always {
            echo 'Fin du pipeline.'
        }
    }
}
