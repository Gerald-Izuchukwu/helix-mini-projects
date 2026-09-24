pipeline {
    agent any

    environment {
        IMAGE_NAME = 'portfolio-website'
        CONTAINER_NAME = 'portfolio-app'
        HOST_PORT = '8081'   // change if 8081 is taken (Jenkins itself uses 8080)
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Static site with no external dependencies — nothing to install. Step included to satisfy pipeline structure.'
            }
        }

        stage('Run Application') {
            steps {
                script {
                    // stop and remove any previous container so re-runs don't clash
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}").run(
                        "--name ${CONTAINER_NAME} -d -p ${HOST_PORT}:80"
                    )
                    sleep 3
                    sh "curl -f http://localhost:${HOST_PORT} || (echo 'App failed to respond' && exit 1)"
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker image prune -f'
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished: SUCCESS'
        }
        failure {
            echo 'Pipeline finished: FAILURE'
        }
    }
}