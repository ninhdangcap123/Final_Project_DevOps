# Final_Project_DevOps

Step 1: Create Terraform files to create resources : RDS, EKS, ECR, VPC, S3, Subnet, SSM, Cluster, ROLES

Step 2: Create Python app to connect to RDS, test run using python app.py

Step 3: Create Dockerfile to build the python app image, test using docker build and docker run 

Step 4: Push the Docker Image to the ECR

Step 5: Deploy the Image to EKS

Step 6: Setup an EC2 Instance and set up jenkins
docker exec -it --user root objective_yonath bash
apt-get update
apt-get install -y curl unzip python3-pip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
docker restart objective_yonath

Step 7: Create CICD job for auto deploy Front End

