aws_region = "ap-south-1"

project_name = "terraform-env-process"

environment = "prod"

# -------------------------
# VPC
# -------------------------

vpc_cidr = "10.30.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

private_subnet_cidrs = [
  "10.30.11.0/24",
  "10.30.12.0/24"
]

# -------------------------
# EC2
# -------------------------

ami_id = "ami-001e7cc215773c7fb"

instance_type = "t3.medium"

key_name = "prod-key"

# -------------------------
# Domain
# -------------------------

domain_name     = "eswar.fun"
route53_zone_id = "Z02126942V8NGM7C9TXK6"

# -------------------------
# EKS
# -------------------------

kubernetes_version = "1.33"

eks_instance_types = [
  "t3.medium"
]

eks_desired_size = 2

eks_min_size = 2

eks_max_size = 5