
output "hosted-zone-name-servers" {
  value = aws_route53_zone.route-53-zone.name_servers
}

output "hosted-zone-id" {
  value = aws_route53_zone.route-53-zone.zone_id
}
