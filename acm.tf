provider "aws" {
  region = "us-east-1" # ACM for API Gateway edge-optimized must be in us-east-1
}

resource "aws_acm_certificate" "monica_cert" {
  domain_name       = "group2-urlshortener.sctp-sandbox.com"
  validation_method = "DNS"

  tags = {
    Name = "Monica ACM Cert"
  }
}

resource "aws_route53_record" "monica_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.monica_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.monica.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "monica_cert_validation" {
  certificate_arn         = aws_acm_certificate.monica_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.monica_cert_validation : record.fqdn]
}
