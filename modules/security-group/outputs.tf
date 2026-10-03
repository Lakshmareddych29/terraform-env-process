output "security_group_ids" {
  description = "Map of security group names to IDs"
  value = {
    for key, sg in aws_security_group.this :
    key => sg.id
  }
}

output "security_group_arns" {
  description = "Map of security group names to ARNs"
  value = {
    for key, sg in aws_security_group.this :
    key => sg.arn
  }
}