terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0" # Specify the desired version range of the AWS provider
    }
  }

  backend "s3" {
    bucket         = "terraform-state-3409094390"  # The S3 bucket where state will be stored
    key            = "terraform/terraform.tfstate" # The path in the bucket to store the state file
    region         = "eu-west-1"                   # The region where your S3 bucket is located
    encrypt        = true                          # Enable encryption for state files
    dynamodb_table = "terraform-lock"              # DynamoDB table for state locking (optional)
    acl            = "private"                     # Set the ACL for the state file
  }
}

provider "aws" {
  region = "eu-west-1"
}


