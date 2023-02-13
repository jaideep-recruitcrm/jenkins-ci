pipeline {
    agent any
    stages {
        stage("Build") {
            steps {
                git 'https://github.com/jaideep-recruitcrm/jenkins-ci.git'
                sh 'composer install'
                sh 'cp .env.example .env'
                sh 'php artisan key:generate'
            }
        }
    }
}
