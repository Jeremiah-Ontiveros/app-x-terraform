terraform {
  backend "s3" {
    bucket         = "app-x-terraform-state-bucket"
    key            = "app-x/env/production/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "app-x-state"
    acl            = "bucket-owner-full-control"
  }
}
