provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "app-x-terraform-state_bucket" {
  bucket = "app-x-terraform-state-${var.env}"

    lifecycle {
    prevent_destroy = true
  }
}

# Public Read-Only Policy with IAM User Full Access
resource "aws_s3_bucket_policy" "app-x-terraform-state_read_policy" {
  bucket = aws_s3_bucket.app-x-terraform-state_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.aws_deployment_user.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.app-x-terraform-state_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.app-x-terraform-state_bucket.id}/*"
      ]
    }
  ]
}
POLICY
}


resource "aws_s3_bucket_versioning" "app-x-terraform-state_bucket" {
    bucket = aws_s3_bucket.app-x-terraform-state_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "app-x-terraform-state_bucket_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}