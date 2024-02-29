terraform {
  backend "s3" {
    bucket  = "alamy-tech-asses-remote-state-file"
    key     = "alamy/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
    #dynamodb_table = "terraform-lock"
  }
}