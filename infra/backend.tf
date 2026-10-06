terraform {
  required_version = ">= 1.6" # minimum Terraform CLI version
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" } # pin the major version
  }
  backend "s3" {
    bucket         = "usman-tfstate-1978"            # where state is stored
    key            = "eks-backend/terraform.tfstate" # path of the state file in the bucket
    region         = "us-east-1"
    dynamodb_table = "tf-locks" # lock so two applies cannot run at once
    encrypt        = true       # encrypt state at rest
  }
}