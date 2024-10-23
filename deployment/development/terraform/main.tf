provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_site" {
  bucket = "ninhnh-vti-bucket-unique-123456"
}

# Configure S3 bucket for website hosting
resource "aws_s3_bucket_website_configuration" "static_site_config" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

# Create a PostgreSQL RDS instance
resource "aws_db_instance" "default" {
  allocated_storage       = 20
  engine                = "postgres"
  engine_version        = "16.3"  # Ensure this version is available
  instance_class        = "db.t4g.micro"
  db_name               = "postgres"  # Changed from name to db_name
  username              = aws_ssm_parameter.db_username.value  # Reference SSM parameter
  password              = aws_ssm_parameter.db_password.value  # Reference SSM parameter
  db_subnet_group_name  = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  skip_final_snapshot   = true
}

# Security group to allow PostgreSQL traffic
resource "aws_security_group" "default" {
  name_prefix = "allow_postgres_"
  description = "Allow Postgres traffic on port 5432"
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
}

# Subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.selected.ids
}

# Data to dynamically fetch the subnets in the VPC
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Data to fetch the default VPC in the region
data "aws_vpc" "selected" {
  default = true
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

# Create an Elastic Container Registry (ECR) to hold container images
resource "aws_ecr_repository" "my_ecr" {
  name = "backend"
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}
