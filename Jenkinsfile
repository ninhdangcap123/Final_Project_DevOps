pipeline {
    agent any
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
    }
    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/ninhdangcap123/Final_Project_DevOps.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("myapp")
                }
            }
        }
        stage('Upload to S3') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'aws s3 cp app/index.html s3://ninhnh-vti-bucket/ --acl public-read'
                    }
                }
            }
        }
        stage('Deploy Python App') {
            steps {
                script {
                    dockerImage.run('-d')
                }
            }
        }
    }
}
