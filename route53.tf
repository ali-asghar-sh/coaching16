# Issue an ACM certificate for the custom domain
resource "aws_acm_certificate" "cert" {
  domain_name       = "group2-urlshortener.sctp-sandbox.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create Route 53 DNS records to validate ACM cert
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
  zone_id = data.aws_route53_zone.main.zone_id
}

# Complete validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Custom domain for API Gateway
resource "aws_api_gateway_domain_name" "custom" {
  domain_name              = "group2-urlshortener.sctp-sandbox.com"
  regional_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Optional: Map to specific base path/stage
resource "aws_api_gateway_base_path_mapping" "mapping" {
  domain_name = aws_api_gateway_domain_name.custom.domain_name
  api_id      = data.aws_api_gateway_rest_api.urlshortener.id
  stage_name  = data.aws_api_gateway_stage.prod.stage_name
}

# Route 53 alias A record pointing to API Gateway
resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "group2-urlshortener.sctp-sandbox.com"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom.regional_zone_id
    evaluate_target_health = true
  }
}
