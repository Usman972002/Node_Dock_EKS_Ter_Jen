data "aws_availability_zones" "available" { state = "available" }

resource "aws_eip" "nat" {
  count  = 1 # one NAT gateway -> one EIP
  domain = "vpc"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name            = "backend-vpc"
  cidr            = "10.0.0.0/16"                                            # pods take VPC IPs, so keep this roomy
  azs             = slice(data.aws_availability_zones.available.names, 0, 3) # 3 AZs for HA
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]            # nodes + pods
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]      # ALB, NAT, Jenkins

  enable_nat_gateway  = true
  single_nat_gateway  = true              # ONE NAT => ONE egress IP to whitelist (cheaper, but a single-AZ dependency)
  reuse_nat_ips       = true              # use the EIP we created instead of auto-creating one
  external_nat_ip_ids = aws_eip.nat[*].id # attach our EIP(s) to the NAT gateway

  enable_dns_hostnames = true # required by EKS
  enable_dns_support   = true

  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }          # internet-facing ALBs are placed here
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 } # internal LBs are placed here
}
