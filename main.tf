provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "covid19_bucket" {
  bucket = "projectpro-covid19-test-data-akash7"
  force_destroy = true
}
 