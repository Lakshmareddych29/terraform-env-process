output "certificate_arn" {
  description = "ACM certificate ARN"

  value = aws_acm_certificate.this.arn
}

output "certificate_id" {
  description = "ACM certificate ID"

  value = aws_acm_certificate.this.id
}

output "certificate_domain_name" {
  description = "Certificate primary domain"

  value = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Certificate status"

  value = aws_acm_certificate_validation.this.id
}