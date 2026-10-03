
# -------------------------
# Application Load Balancer
# -------------------------

resource "aws_lb" "this" {
  name = "${var.project_name}-${var.environment}-alb"

  load_balancer_type = "application"

  internal = var.internal

  subnets = var.subnet_ids

  security_groups = var.security_group_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}


# -------------------------
# Target Group
# -------------------------

resource "aws_lb_target_group" "this" {
  name = "${var.project_name}-${var.environment}-tg"

  port     = var.target_port
  protocol = var.target_protocol

  vpc_id = var.vpc_id

  target_type = var.target_type

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-target-group"
    }
  )
}


# -------------------------
# Target Group Attachments
# -------------------------

resource "aws_lb_target_group_attachment" "this" {
  count = length(var.target_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_ids[count.index]
  port             = var.target_port
}


# -------------------------
# HTTP Listener
# -------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]

      content {
        target_group {
          arn = aws_lb_target_group.this.arn
        }
      }
    }

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}


# -------------------------
# HTTPS Listener
# -------------------------

resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn

  port     = 443
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.this.arn
      }
    }
  }
}