variable "region" { default = "us-east-1" }
variable "cluster_name" { default = "backend-eks" }
variable "my_ip_cidr" { default = "49.47.254.45/32" } # your public IP as x.x.x.x/32 (SSH, Jenkins UI, EKS API)
variable "key_name" { default = "jenkins-eks" }   # existing EC2 key pair for Jenkins
