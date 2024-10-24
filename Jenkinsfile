pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        S3_BUCKET = 'ninhnh-vti-bucket-static-web'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/ninhdangcap123/Final_Project_DevOps.git'
            }
        }
        stage('Deploy to S3') {
            steps {
                script {
                    // Deploy the HTML file to S3
                    sh 'aws s3 sync . s3://$S3_BUCKET --exclude "*" --include "index.html"'
                }
            }
        }
    }
}
