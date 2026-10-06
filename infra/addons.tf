module "lb_irsa" {
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                                = "~> 5.44"
  role_name                              = "aws-lb-controller"
  attach_load_balancer_controller_policy = true # official controller IAM policy
  oidc_providers = { main = {
    provider_arn               = module.eks.oidc_provider_arn
    namespace_service_accounts = ["kube-system:aws-load-balancer-controller"] # only this ServiceAccount may assume the role
  } }
}

module "ebs_csi_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.44"
  role_name = "ebs-csi"
  attach_ebs_csi_policy = true
  oidc_providers = { main = { provider_arn = module.eks.oidc_provider_arn
                              namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"] } }
}
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
}
