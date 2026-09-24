pipeline {
    agent any
    stages {
<<<<<<< HEAD
        stage('Build') {
            steps {
                echo '🛠️ Build en cours...'
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
=======
        stage('Build') { steps { echo "Build de la branche ${env.BRANCH_NAME}" } }
    }
}
>>>>>>> d9a0771490aa1c241f3f72d7ac4475a2d1558fff
