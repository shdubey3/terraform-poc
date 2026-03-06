terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
# Credentials are automatically loaded from ~/.aws/credentials file
# Set the profile to match the one in your credentials file, or leave empty to use [default]
provider "aws" {
  region  = var.aws_region
  profile = "default"  # Change to your profile name if using a specific profile
}
