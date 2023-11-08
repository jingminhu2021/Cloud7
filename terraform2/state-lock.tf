terraform {
  backend "s3" {
    bucket         = "cloud7-bucket-terraform-state"
    key            = "key/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "my-terraform-lock-table"
    encrypt        = true
  }
}
