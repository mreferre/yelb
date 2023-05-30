terraform {
  backend "s3" {
    bucket = "circlecidemos3"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }
}