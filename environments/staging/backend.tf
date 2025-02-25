terraform {
  backend "s3" {
    bucket         = "app-x-terraform-state-bucket"
    key            = "app-x/env/staging/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "app-x-state"
    acl            = "bucket-owner-full-control"
  }
}
