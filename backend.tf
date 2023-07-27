# Push state file to cloud
terraform {
  backend "s3" {
    bucket         = "prophius-buck"
    key            = "prophius/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prophius-locks"
    encrypt        = true
  }
}