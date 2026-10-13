
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        echo "Compilation en cours..."
                        sh 'exit 1' // Simulation d'une erreur
                    } catch (Exception e) {
                        echo "Erreur détectée dans le build !"
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
    }
    post {
        failure {
            echo "Le pipeline a échoué, envoi d’une notification..."
            sh 'echo "Erreur détectée" > erreur.log'
            archiveArtifacts artifacts: 'erreur.log', fingerprint: true
        }
        success {
            echo "Pipeline exécuté avec succès !"
        }
    }
}
