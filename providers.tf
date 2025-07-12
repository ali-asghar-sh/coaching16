provider "aws" {
  region = "ap-southeast-1"
}

data "aws_route53_zone" "group_zone" {
  name = "sctp-sandbox.com"
}

