provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "my-website-staging"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_db_instance" "default" {
  engine           = "postgres"
  instance_class   = "db.t2.micro"
  allocated_storage = 20
  name             = "staging_dbname"
  username         = "admin"
  password         = "yourpassword123"
  skip_final_snapshot = true

  tags = {
    Name = "staging-DB"
  }
}
