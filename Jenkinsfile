pipeline {
    agent any
    stages {
        stage("Build") {
            steps {
                git 'https://github.com/jaideep-recruitcrm/jenkins-ci.git'
                sh 'composer update --ignore-platform-reqs'
                sh 'cp .env.example .env'
                sh 'php artisan key:generate'
            }
        }
        stage("Unit test") {
            steps {
                sh 'php artisan test'
            }
        }
        stage("Code coverage") {
            steps {
                sh "./vendor/bin/phpunit --coverage-html 'reports/coverage'"
            }
        }
        stage("Static code analysis larastan") {
            steps {
                sh "./vendor/bin/phpstan analyse --memory-limit=2G"
            }
        }
        stage("Acceptance test codeception") {
            steps {
                sh "./vendor/bin/codecept run"
            }
        }
    }
}
