terraform {
  backend "s3" {
    bucket         = "tngs-tfstate"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" # optional but recommended
    encrypt        = true
  }
}