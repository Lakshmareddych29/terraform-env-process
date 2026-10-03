module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


# ============================================================
# ALB SECURITY GROUP
# ============================================================

module "alb_security_group" {
  source = "../../modules/security-group"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    alb = {
      name        = "${var.project_name}-${var.environment}-alb-sg"
      description = "Security group for Application Load Balancer"

      ingress_rules = [
        {
          description = "HTTP"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTPS"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      egress_rules = [
        {
          description = "Allow all outbound traffic"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# EC2 SECURITY GROUP
# ============================================================

module "ec2_security_group" {
  source = "../../modules/security-group"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    ec2 = {
      name        = "${var.project_name}-${var.environment}-ec2-sg"
      description = "Security group for EC2"

      ingress_rules = [
        {
          description = "HTTP from ALB"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          security_groups = [
            module.alb_security_group.security_group_ids["alb"]
          ]
        }
      ]

      egress_rules = [
        {
          description = "Allow outbound"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# EC2
# ============================================================

module "ec2" {
  source = "../../modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type

  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_ids = [
    module.ec2_security_group.security_group_ids["ec2"]
  ]

  key_name = var.key_name

  associate_public_ip = false

  root_volume_size = 20
  root_volume_type = "gp3"

  instance_name = "${var.project_name}-${var.environment}-server"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# ECR
# ============================================================

module "ecr" {
  source = "../../modules/ecr"

  repositories = {
    frontend = {
      name                 = "${var.project_name}-${var.environment}-frontend"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      encryption_type      = "AES256"

      enable_lifecycle_policy = true
      keep_image_count        = 10
    }

    backend = {
      name                 = "${var.project_name}-${var.environment}-backend"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      encryption_type      = "AES256"

      enable_lifecycle_policy = true
      keep_image_count        = 10
    }
  }
}


# ============================================================
# EKS
# ============================================================

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  subnet_ids = module.vpc.private_subnet_ids

  kubernetes_version = var.kubernetes_version

  instance_types = var.eks_instance_types

  capacity_type = "ON_DEMAND"

  desired_size = var.eks_desired_size
  min_size     = var.eks_min_size
  max_size     = var.eks_max_size

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# SSM PARAMETERS
# ============================================================

module "ssm_parameter" {
  source = "../../modules/ssm-parameter"

  parameters = {
    vpc_id = {
      name        = "/${var.project_name}/${var.environment}/vpc_id"
      description = "VPC ID"
      type        = "String"
      value       = module.vpc.vpc_id
    }

    public_subnet_ids = {
      name        = "/${var.project_name}/${var.environment}/public_subnet_ids"
      description = "Public subnet IDs"
      type        = "StringList"
      value       = join(",", module.vpc.public_subnet_ids)
    }

    private_subnet_ids = {
      name        = "/${var.project_name}/${var.environment}/private_subnet_ids"
      description = "Private subnet IDs"
      type        = "StringList"
      value       = join(",", module.vpc.private_subnet_ids)
    }
  }
}


# ============================================================
# ROUTE 53
# ============================================================

module "route53" {
  source = "../../modules/route53"

  project_name = var.project_name
  environment  = var.environment

  domain_name = var.domain_name
  zone_id     = var.route53_zone_id

  records = {
    app = {
      name = "uat.${var.domain_name}"
      type = "A"

      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# ACM
# ============================================================

module "acm" {
  source = "../../modules/acm"

  project_name = var.project_name
  environment  = var.environment

  domain_name = var.domain_name

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  route53_zone_id = module.route53.zone_id

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# ALB
# ============================================================

module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  internal     = false

  # Nginx listens on port 80
  target_port = 80

  target_protocol = "HTTP"

  target_type = "instance"

  target_ids = [
    module.ec2.instance_id
  ]

  health_check_path = "/"

  enable_https = true

  certificate_arn = module.acm.certificate_arn

  security_group_ids = [
    module.alb_security_group.security_group_ids["alb"]
  ]

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}