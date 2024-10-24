pipeline {
    agent any

    environment {
        // Set your AWS region, if necessary
        AWS_REGION = 'us-east-1' // Change to your desired region
        AWS_DEFAULT_REGION = "${AWS_REGION}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone your Git repository containing the HTML file
                git 'https://github.com/ninhdangcap123/Final_Project_DevOps'
            }
        }

        stage('Build') {
            steps {
                // (Optional) Any build steps you need, e.g., packaging or processing
                echo 'Building...'
            }
        }

        stage('Deploy to S3') {
            steps {
                script {
                    // AWS CLI commands to sync your local directory with the S3 bucket
                    sh '''
                    aws s3 sync . s3://ninhnh-vti-bucket-static-web --delete --region ${AWS_REGION}
                    '''
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
