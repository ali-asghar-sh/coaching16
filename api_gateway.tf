resource "aws_api_gateway_domain_name" "monica_domain" {
  domain_name = "group2-urlshortener.sctp-sandbox.com"

  endpoint_configuration {
    types = ["EDGE"]
  }

  regional_certificate_arn = null
  certificate_arn          = aws_acm_certificate_validation.monica_cert_validation.certificate_arn
}

resource "aws_api_gateway_base_path_mapping" "monica_path_mapping" {
  api_id      = aws_api_gateway_rest_api.monica_api.id
  stage_name  = aws_api_gateway_deployment.monica_deploy.stage_name
  domain_name = aws_api_gateway_domain_name.monica_domain.domain_name
}
