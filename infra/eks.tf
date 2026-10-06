module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = "1.33" # verify it is supported when you run this
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets # nodes live in private subnets only

  cluster_endpoint_public_access           = true                                                # kubectl from laptop/Jenkins over the internet
  cluster_endpoint_public_access_cidrs     = [var.my_ip_cidr, "${aws_eip.jenkins.public_ip}/32"] # only these may reach the API
  enable_cluster_creator_admin_permissions = true                                                # whoever runs terraform becomes cluster admin
  enable_irsa                              = true                                                # OIDC provider for IAM Roles for Service Accounts

  cluster_addons = {
    coredns    = { most_recent = true } # in-cluster DNS
    kube-proxy = { most_recent = true } # service networking
    vpc-cni    = { most_recent = true } # pods get VPC IPs
  }

  access_entries = { # modern replacement for the aws-auth ConfigMap
    jenkins = {
      principal_arn = aws_iam_role.jenkins.arn
      policy_associations = {
        deploy = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = { type = "namespace", namespaces = ["backend"] } # Jenkins may only touch ns "backend"
        }
      }
    }
  }

  eks_managed_node_groups = {
    general = {
      instance_types = ["c7i-flex.large"]
      min_size       = 2, max_size = 4, desired_size = 2
      disk_size      = 30
      labels         = { workload = "general" }
    }
  }
}
