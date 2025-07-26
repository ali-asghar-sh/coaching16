output "custom_domain_url" {
  value = "https://${aws_api_gateway_domain_name.monica_domain.domain_name}"
}
