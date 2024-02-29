provider "aws" {
  region = "ap-south-1"
}


terraform {
  required_providers {
    aws = {
        source = "aws"
        version = "~>5.0"
    }
  }
}