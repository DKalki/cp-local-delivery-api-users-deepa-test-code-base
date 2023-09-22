#Create the parameter store entries

#Create the KMS key
resource "aws_kms_key" "kms-key" {
  #checkov:skip=CKV2_AWS_64: "Ensure KMS key Policy is defined"
  description             = local.kms-key-name
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = var.default-tags
}

#Create the KMS key alias for database encryption
#This is used by other components to locate the key by name
resource "aws_kms_alias" "kms-key-alias" {
  name          = local.kms-alias-name
  target_key_id = aws_kms_key.kms-key.key_id
}

resource "aws_ssm_parameter" "audit-external-id" {
  overwrite   = true
  type        = "SecureString"
  key_id      = aws_kms_key.kms-key.key_id
  name        = local.audit-external-id-param-name
  value       = var.audit-external-id
  description = "Audit external id"
  tags        = var.default-tags
}

resource "aws_ssm_parameter" "logging-external-id" {
  overwrite   = true
  type        = "SecureString"
  key_id      = aws_kms_key.kms-key.key_id
  name        = local.logging-external-id-param-name
  value       = var.logging-external-id
  description = "Logging external id"
  tags        = var.default-tags
}
