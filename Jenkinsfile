pipeline {

    agent any

    environment {

        // Utilisateur Docker Hub
        DOCKER_USER = 'dockerID'

        // Repository Docker en minuscules
        DOCKER_IMAGE = 'dockerID/microapp'

        // Variables applicatives
        APP_NAME = ''
        APP_PORT = ''
        APP_VERSION = ''
    }

    stages {

        // ============================================================
        // 1. Lecture du fichier .env
        // ============================================================

        stage('Charger .env') {

            steps {

                script {

                    def config = [:]

                    def envFile = readFile('.env')

                    envFile.split('\n').each { line ->

                        line = line.trim()

                        // Ignore les lignes vides et les commentaires
                        if (line && !line.startsWith('#')) {

                            def parts = line.split('=', 2)

                            if (parts.size() == 2) {

                                def key = parts[0].trim()
                                def value = parts[1].trim()

                                config[key] = value
                            }
                        }
                    }

                    // Docker exige un repository en minuscules
                    env.APP_NAME = config['APP_NAME']?.toLowerCase()
                    env.APP_PORT = config['APP_PORT']
                    env.APP_VERSION = config['APP_VERSION']

                    echo "========================================"
                    echo "Configuration de l'application"
                    echo "========================================"
                    echo "Application : ${env.APP_NAME}"
                    echo "Port        : ${env.APP_PORT}"
                    echo "Version     : ${env.APP_VERSION}"
                    echo "Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}"
                    echo "========================================"
                }
            }
        }

        // ============================================================
        // 2. Build Docker
        // ============================================================

        stage('Build Docker') {

            steps {

                echo "🐳 Construction de l'image Docker..."

                sh """
                    docker build \
                        -t ${env.DOCKER_IMAGE}:${env.APP_VERSION} \
                        -t ${env.DOCKER_IMAGE}:latest \
                        .
                """

                echo "✅ Image Docker construite"

                sh """
                    docker images ${env.DOCKER_IMAGE}
                """
            }
        }

        // ============================================================
        // 3. Login Docker Hub
        // ============================================================

        stage('Login Docker Hub') {

            steps {

                withCredentials([
                    string(
                        credentialsId: 'DOCKER_PASSWORD',
                        variable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin
                    '''
                }

                echo "✅ Connexion à Docker Hub réussie"
            }
        }

        // ============================================================
        // 4. Push Docker
        // ============================================================

        stage('Push Docker') {

            steps {

                echo "📦 Publication sur Docker Hub..."

                sh """
                    docker push ${env.DOCKER_IMAGE}:${env.APP_VERSION}
                    docker push ${env.DOCKER_IMAGE}:latest
                """

                echo "✅ Image publiée sur Docker Hub"
            }
        }

        // ============================================================
        // 5. Deploy uniquement sur main
        // ============================================================

        stage('Deploy') {

            when {
                branch 'main'
            }

            steps {

                echo """
                ========================================
                🚀 DÉPLOIEMENT EN PRODUCTION
                ========================================

                Application : ${env.APP_NAME}
                Version     : ${env.APP_VERSION}
                Port        : ${env.APP_PORT}
                Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}

                ========================================
                """

                // Déploiement simulé pour le TP
                sh '''
                    echo "Déploiement en cours..."
                    sleep 3
                    echo "✅ Déploiement terminé"
                '''
            }
        }
    }

    // ================================================================
    // Actions finales
    // ================================================================

    post {

        success {

            echo """
            ========================================
            ✅ PIPELINE RÉUSSIE
            ========================================

            Application : ${env.APP_NAME}
            Version     : ${env.APP_VERSION}
            Image       : ${env.DOCKER_IMAGE}:${env.APP_VERSION}

            ========================================
            """
        }

        failure {

            echo """
            ========================================
            ❌ PIPELINE EN ÉCHEC
            ========================================

            Application : ${env.APP_NAME ?: 'inconnue'}
            Version     : ${env.APP_VERSION ?: 'inconnue'}

            ========================================
            """
        }

        always {

            echo "🏁 Fin du pipeline"
        }
    }
}
