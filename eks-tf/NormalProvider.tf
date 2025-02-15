# Configure the AWS provider with the specified region
provider "aws" {
  region = "us-west-2" # AWS region where resources will be deployed
}

# Define Terraform settings, including required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Source of the AWS provider
      version = "~> 4.56"        # Version constraint for the AWS provider
    }
  }
}
