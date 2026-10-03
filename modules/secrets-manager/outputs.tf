output "secret_ids" {
  description = "Secret IDs"

  value = {
    for key, secret in aws_secretsmanager_secret.this :
    key => secret.id
  }
}

output "secret_arns" {
  description = "Secret ARNs"

  value = {
    for key, secret in aws_secretsmanager_secret.this :
    key => secret.arn
  }
}

output "secret_names" {
  description = "Secret names"

  value = {
    for key, secret in aws_secretsmanager_secret.this :
    key => secret.name
  }
}