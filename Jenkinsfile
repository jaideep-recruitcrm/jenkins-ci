pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials("aws-access-key-id")
        AWS_SECRET_ACCESS_KEY = credentials("aws-secret-access-key")
    }
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
            }
        }
        stage("Unit test") {
            steps {
                sh 'php artisan test'
            }
        }
        stage("Code coverage") {
            steps {
                sh "vendor/bin/phpunit --coverage-html 'reports/coverage'"
            }
        }
        stage("Static code analysis larastan") {
            steps {
                sh "vendor/bin/phpstan analyse --memory-limit=2G"
            }
        }
        stage("Static code analysis phpcs") {
            steps {
                sh "vendor/bin/phpcs"
            }
        }
        stage("Docker build") {
            steps {
                sh "docker 2>/dev/null 1>&2 rmi `docker rmi 309853523083.dkr.ecr.ap-south-1.amazonaws.com` || true"
                sh "docker build -t 309853523083.dkr.ecr.ap-south-1.amazonaws.com/jenkins-ci --no-cache ."
            }
        }
        stage("Docker push") {
            environment {
                ECR_USERNAME = credentials("ecr-user")
                ECR_PASSWORD = credentials("ecr-password")
            }
            steps {
                sh "cat /tmp/ecr_password.txt | docker login --username ${ECR_USERNAME} --password-stdin 309853523083.dkr.ecr.ap-south-1.amazonaws.com"
                sh "docker push 309853523083.dkr.ecr.ap-south-1.amazonaws.com/jenkins-ci"
            }
        }
        stage("Deploy to staging") {
            steps {
                sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                sh "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                sh "ssh-agent sh -c 'ssh-add /etc/ansible/pem/key.pem && ansible-playbook /etc/ansible/playbook/playbook-staging-run.yml'"
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
                sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                sh "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                sh "ssh-agent sh -c 'ssh-add /etc/ansible/pem/key.pem && ansible-playbook /etc/ansible/playbook/playbook-staging-acceptance.yml'"
            }
            post {
                always {
                    sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                    sh "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                    sh "ssh-agent sh -c 'ssh-add /etc/ansible/pem/key.pem && ansible-playbook /etc/ansible/playbook/playbook-staging-stop.yml'"
                }
            }
        }
        stage("Release") {
            steps {
                sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                sh "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                sh "ssh-agent sh -c 'ssh-add /etc/ansible/pem/key.pem && ansible-playbook /etc/ansible/playbook/playbook-production-run.yml'"
            }
        }
        stage("Smoke test") {
            steps {
                sleep 20
                sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                sh "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                sh "ssh-agent sh -c 'ssh-add /etc/ansible/pem/key.pem && ansible-playbook /etc/ansible/playbook/playbook-production-acceptance.yml'"
            }
        }
    }
}