output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.zone_id
}


output "zone_name" {
  description = "Route53 hosted zone name"
  value       = var.domain_name
}

output "record_names" {
  description = "Route53 record names"
  value       = [
    for record in aws_route53_record.this : record.name
  ]
}