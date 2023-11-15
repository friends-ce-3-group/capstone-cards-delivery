terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "sctp-ce3-tfstate-bucket-1"
    key    = "friends-capstone-notification.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}