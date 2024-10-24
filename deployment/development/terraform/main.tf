provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ninhnh-vti-vpc"
  }
}

# Retrieve availability zones
data "aws_availability_zones" "available" {}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                 = aws_vpc.default.id
  cidr_block             = "10.0.${count.index}.0/24"
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "ninhnh-vti-public-subnet-${count.index}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "ninhnh-vti-internet-gateway"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_site" {
  bucket = "ninhnh-vti-bucket-static-web"

  tags = {
    Name = "ninhnh-vti-static-site-bucket"
  }
}

# Configure S3 bucket for website hosting
resource "aws_s3_bucket_website_configuration" "static_site_config" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

# Security group to allow PostgreSQL traffic
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres_security_group"
  }
}

# Create a subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = aws_subnet.public_subnet[*].id

  tags = {
    Name = "ninhnh-vti-rds-subnet-group"
  }
}

# Define variables for sensitive data
variable "db_username" {
  type        = string
  description = "Username for PostgreSQL database"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Password for PostgreSQL database"
  default     = "ninhdangcap123"
}

# Store the database username in SSM Parameter Store
resource "aws_ssm_parameter" "db_username" {
  name        = "/ninhnh/db_username"
  description = "Username for PostgreSQL database"
  type        = "SecureString"
  value       = var.db_username
}

# Store the database password in SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name        = "/ninhnh/db_password"
  description = "Password for PostgreSQL database"
  type        = "SecureString"
  value       = var.db_password
}

# Data source to retrieve the SSM parameter for the database username
data "aws_ssm_parameter" "db_username" {
  name = aws_ssm_parameter.db_username.name
}

# Data source to retrieve the SSM parameter for the database password
data "aws_ssm_parameter" "db_password" {
  name            = aws_ssm_parameter.db_password.name
  with_decryption = true
}

# Create a PostgreSQL RDS instance
resource "aws_db_instance" "default" {
allocated_storage       = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t4g.micro"
  db_name                = "postgres"

  username               = data.aws_ssm_parameter.db_username.value
  password               = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  skip_final_snapshot    = true
  publicly_accessible     = true

  depends_on = [
    aws_ssm_parameter.db_username,
    aws_ssm_parameter.db_password
  ]

  tags = {
    Name = "ninhnh-vti-postgres-db-instance"
  }
}

# Create an Elastic Container Registry (ECR) to hold container images
resource "aws_ecr_repository" "my_ecr" {
  name = "backend"

  tags = {
    Name = "ninhnh-vti-ecr"
  }
}

# Create an EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "ninhnh-vti-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public_subnet[*].id
  }

  tags = {
    Name = "ninhnh-vti-cluster"
  }
}

# IAM role for EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })

  tags = {
    Name = "ninhnh-vti-eks-cluster-role"
  }
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}
