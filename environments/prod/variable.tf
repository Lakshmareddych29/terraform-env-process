variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# -------------------------
# VPC
# -------------------------

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

# -------------------------
# EC2
# -------------------------

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair"
  type        = string
}



# -------------------------
# Domain
# -------------------------

variable "domain_name" {
  description = "Domain name"
  type        = string
}


variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
}

# -------------------------
# EKS
# -------------------------

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "eks_instance_types" {
  description = "EKS worker node instance types"
  type        = list(string)
}

variable "eks_desired_size" {
  description = "Desired EKS nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Minimum EKS nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum EKS nodes"
  type        = number
}