terraform {
  backend "s3" {
    bucket	= "app-x-terraform-state"
    key		= "terraform.tfstate"
    region	= "us-east-2"
    dynamodb_table = "app-x-terraform-locks"
  }
}
