aws_region = "ap-south-1"

project_name = "terraform-env-process"

environment = "dev"

# -------------------------
# VPC
# -------------------------

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# -------------------------
# EC2
# -------------------------

ami_id = "ami-001e7cc215773c7fb"

instance_type = "t3.micro"

key_name = "my-key"


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

eks_desired_size = 1

eks_min_size = 1

eks_max_size = 2