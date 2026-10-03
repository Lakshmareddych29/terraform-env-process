resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.value

  tier = each.value.tier

  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}