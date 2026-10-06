provider "aws" {
  region = var.region                                                          # default region for every resource
  default_tags { tags = { Project = "eks-backend", ManagedBy = "terraform" } } # tag everything
}