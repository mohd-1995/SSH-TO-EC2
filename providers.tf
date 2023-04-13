terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  // shared_credentials_files = ["/Users/mo_b/Desktop/projects/pythonProject/aws_credentials"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "creating-dev"

}