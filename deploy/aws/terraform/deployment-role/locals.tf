locals {
  name_prefix = var.instance
  role_name   = "${local.name_prefix}-ld-plat-rol-deployment"
  policy_name = "${local.name_prefix}-ld-plat-pol-deployment_role_policy"
  iam_extended_policy_name = "${local.name_prefix}-ld-plat-pol-deployment_extended_policy"
}
