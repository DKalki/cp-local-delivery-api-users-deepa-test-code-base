locals {
  name-prefix  = var.instance
  kms-key-name = "${local.name-prefix}-ld-stor-kk-cloudwatch"
}
