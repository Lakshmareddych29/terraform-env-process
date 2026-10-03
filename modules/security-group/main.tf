resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  # -------------------------
  # INGRESS RULES
  # -------------------------
  dynamic "ingress" {
    for_each = each.value.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol

      cidr_blocks = lookup(
        ingress.value,
        "cidr_blocks",
        []
      )

      security_groups = lookup(
        ingress.value,
        "security_groups",
        []
      )
    }
  }

  # -------------------------
  # EGRESS RULES
  # -------------------------
  dynamic "egress" {
    for_each = each.value.egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol

      cidr_blocks = lookup(
        egress.value,
        "cidr_blocks",
        []
      )

      security_groups = lookup(
        egress.value,
        "security_groups",
        []
      )
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}