
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "🛠️ Build de la branche ${env.BRANCH_NAME}"
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo '✅ Tests unitaires...'
                sh 'mvn test'
            }
        }
    }
}
