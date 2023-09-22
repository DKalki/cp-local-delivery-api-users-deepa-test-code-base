locals {
  name-prefix                    = var.instance
  kms-key-name                   = "${local.name-prefix}-ld-stor-kk-paramstore"
  kms-alias-name                 = "alias/${local.name-prefix}-ld-stor-kk-paramstore"
  audit-external-id-param-name   = "${local.name-prefix}-ld-stor-ps-audit_external_id"
  logging-external-id-param-name = "${local.name-prefix}-ld-stor-ps-logging_external_id"
}
