data "aws_route53_zone" "hosted-zone" {
  name = var.hosted-zone-name
}
