# Look up your existing Route 53 hosted zone
data "aws_route53_zone" "main" {
  name         = "sctp-sandbox.com"
  private_zone = false
}

# Reference existing API Gateway by ID
data "aws_api_gateway_rest_api" "urlshortener" {
  rest_api_id = "6ydl3tqyoa"
}

# Reference an existing deployment stage (update "prod" if needed)
data "aws_api_gateway_stage" "prod" {
  rest_api_id = data.aws_api_gateway_rest_api.urlshortener.id
  stage_name  = "prod"
}
