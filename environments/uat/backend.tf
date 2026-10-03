terraform {
  backend "s3" {
    bucket = "terraform-env-process-state"

    key = "uat/terraform.tfstate"

    region = "ap-south-1"

    encrypt = true
  }
}