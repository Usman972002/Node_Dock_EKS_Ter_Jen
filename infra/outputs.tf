output "nat_public_ip" { value = aws_eip.nat[0].public_ip } # <-- give THIS IP to the DB allow-list
output "vpc_id" { value = module.vpc.vpc_id }
output "jenkins_ip" { value = aws_eip.jenkins.public_ip }
output "ecr_url" { value = aws_ecr_repository.backend.repository_url }
output "lb_role_arn" { value = module.lb_irsa.iam_role_arn }
