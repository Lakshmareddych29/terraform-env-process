# -------------------------
# ACM Certificate
# -------------------------

resource "aws_acm_certificate" "this" {
  domain_name = "eswar.fun"

  subject_alternative_names = var.subject_alternative_names

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-certificate"
    }
  )
}

# -------------------------
# Route53 DNS Validation Record
# -------------------------

resource "aws_route53_record" "validation" {
  for_each = {
    for option in aws_acm_certificate.this.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  allow_overwrite = true

  name = each.value.name
  type = each.value.type
  zone_id = var.route53_zone_id

  records = [each.value.record]

  ttl = 60
}

# -------------------------
# Certificate Validation
# -------------------------

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}