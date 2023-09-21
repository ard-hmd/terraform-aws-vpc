# Specify the required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Define the source of the AWS provider
      version = "~> 5.0"        # Specify the version constraint for the AWS provider
    }
  }
}

# Configure the AWS provider settings
provider "aws" {
  region = var.aws_region # Set the AWS region using the value from the 'aws_region' variable
}
