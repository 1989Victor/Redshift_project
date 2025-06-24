terraform {
  backend "s3" {
    bucket = "redshift-state-file"
    key    = "redshift/redshift.tfstate"
    region = "us-east-1"
  }
}