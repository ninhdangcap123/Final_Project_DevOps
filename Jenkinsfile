pipeline {
    agent any

    environment {
        // Set your AWS region, if necessary
        AWS_REGION = 'us-east-1' // Change to your desired region
        AWS_DEFAULT_REGION = "${AWS_REGION}"
    }

    stages {
        stage('Check User') {
            steps {
                sh 'whoami'
            }
        }


        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/ninhdangcap123/Final_Project_DevOps.git', branch: 'main'
            }
        }

        stage('Check AWS CLI') {
            steps {
                sh 'echo $PATH'
                sh 'aws --version'
            }
        }

        stage('Deploy to S3') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        // AWS CLI commands to sync your local directory with the S3 bucket
                        sh '''
                        aws s3 sync . s3://ninhnh-vti-bucket-static-web --delete --region us-east-1 --exclude "*" --include "*.html"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment to S3 was successful!'
        }
        failure {
            echo 'Deployment to S3 failed.'
        }
    }
}
