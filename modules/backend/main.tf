provider "aws" {
  region = "us-east-2"
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "app-x-terraform-state-bucket" {
  bucket = "app-x-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true 
  }
}
resource "aws_s3_bucket_versioning" "app-x-terraform-state-bucket" {
  bucket = aws_s3_bucket.app-x-terraform-state-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "app-x-terraform-state-bucket-lock" {
  name           = "app-x-state"
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "Terraform"
  }
}
