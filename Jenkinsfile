pipeline {
    agent any
    stages {
        stage("Build") {
            environment {
                DB_HOST = credentials("laravel-host")
                DB_DATABASE = credentials("laravel-database")
                DB_USERNAME = credentials("laravel-user")
                DB_PASSWORD = credentials("laravel-password")
            }
            steps {
                sh 'php --version'
                sh 'composer install'
                sh 'composer --version'
                sh 'cp .env.example .env'
                sh 'echo DB_HOST=${DB_HOST} >> .env'
                sh 'echo DB_USERNAME=${DB_USERNAME} >> .env'
                sh 'echo DB_DATABASE=${DB_DATABASE} >> .env'
                sh 'echo DB_PASSWORD=${DB_PASSWORD} >> .env'
                sh 'php artisan key:generate'
                sh 'cp .env .env.testing'
                sh 'php artisan migrate'
                sh 'sed -ri "s/(\\b[0-9]{1,3}\\.){3}[0-9]{1,3}\\b/$(dig +short myip.opendns.com @resolver1.opendns.com)/g" ./tests/acceptance.suite.yml'
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
        stage("Static code analysis phpcs") {
            steps {
                sh "./vendor/bin/phpcs"
            }
        }
        stage("Docker build") {
            steps {
                sh "docker build -t 309853523083.dkr.ecr.ap-south-1.amazonaws.com/jenkins-ci ."
            }
        }
        stage("Docker push") {
            environment {
                ECR_USERNAME = credentials("ecr-user")
                ECR_PASSWORD = credentials("ecr-password")
            }
            steps {
                sh "docker login --username ${ECR_USERNAME} --password ${ECR_PASSWORD} 309853523083.dkr.ecr.ap-south-1.amazonaws.com"
                sh "docker push 309853523083.dkr.ecr.ap-south-1.amazonaws.com/jenkins-ci"
            }
        }
        stage("Deploy to staging") {
            steps {
                sh "docker run -d --rm -p 80:80 --name laravel 309853523083.dkr.ecr.ap-south-1.amazonaws.com/jenkins-ci"
            }
        }
        stage("Acceptance test curl") {
            steps {
                sleep 20
                sh "chmod +x acceptance_test.sh && ./acceptance_test.sh"
            }
        }
        stage("Acceptance test codeception") {
            steps {
                sh "./vendor/bin/codecept run"
            }
            post {
                always {
                    sh "docker stop laravel"
                    sh "docker system prune -a -f --volumes"
                }
            }
        }
    }
}