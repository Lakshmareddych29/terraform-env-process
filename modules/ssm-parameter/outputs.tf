output "parameter_names" {
  description = "Created SSM parameter names"

  value = {
    for key, parameter in aws_ssm_parameter.this :
    key => parameter.name
  }
}

output "parameter_arns" {
  description = "Created SSM parameter ARNs"

  value = {
    for key, parameter in aws_ssm_parameter.this :
    key => parameter.arn
  }
}