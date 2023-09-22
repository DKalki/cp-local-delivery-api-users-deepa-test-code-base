resource "aws_kms_key" "cloudwatch-kms-key" {
  description             = local.kms-key-name
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true

  policy = templatefile(
    "${path.module}/templates/iam-policies/assume-policy.tpl",
    {
      aws-region = var.aws_region
      account-id = var.account-id
    }
  )

  tags = var.default-tags
}

resource "aws_kms_alias" "cloudwatch-kms-key-alias" {
  name          = "alias/${local.kms-key-name}"
  target_key_id = aws_kms_key.cloudwatch-kms-key.key_id
}
