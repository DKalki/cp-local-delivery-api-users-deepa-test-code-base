locals {
  name_prefix                      = var.instance
  route_53_name                    = "api"
  instance_prefixed_route_53_name  = "${local.name_prefix}.api"
  waf_name                         = "${local.name_prefix}-ld-net-waf"
}
