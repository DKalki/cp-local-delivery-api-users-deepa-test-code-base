#Create the KMS key for SQS Encryption
resource "aws_kms_key" "sqs_psc_encrypt" {
  description             = "${var.instance}-ld-stor-kk-sqs-psc"
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true
  policy = templatefile(
    "${path.module}/templates/iam_policies/sqs-policy.tpl",
    {
      account-id = var.account-id
      instance   = var.instance
  })
  tags = var.default-tags
}

resource "aws_kms_key" "sqs_external_encrypt" {
  description             = "${var.instance}-ld-stor-kk-sqs-external"
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true
  policy = templatefile(
    "${path.module}/templates/iam_policies/sqs-policy.tpl",
    {
      account-id = var.account-id
      instance   = var.instance
  })
  tags = var.default-tags
}

resource "aws_kms_key" "sns_encrypt" {
  description             = "${var.instance}-ld-stor-kk-sns"
  deletion_window_in_days = 10
  is_enabled              = true
  enable_key_rotation     = true
  policy = templatefile(
    "${path.module}/templates/iam_policies/sns-policy.tpl",
    {
      account-id = var.account-id
      instance   = var.instance
  })
  tags = var.default-tags
}


#This is used by other components to locate the key by name
resource "aws_kms_alias" "sqs_encrypt_psc_alias" {
  name          = "alias/${var.instance}-ld-stor-kk-sqs-psc"
  target_key_id = aws_kms_key.sqs_psc_encrypt.key_id
}

resource "aws_kms_alias" "sqs_external_encrypt_alias" {
  name          = "alias/${var.instance}-ld-stor-kk-sqs-external"
  target_key_id = aws_kms_key.sqs_external_encrypt.key_id
}

resource "aws_kms_alias" "sns_encrypt_alias" {
  name          = "alias/${var.instance}-ld-stor-kk-sns"
  target_key_id = aws_kms_key.sns_encrypt.key_id
}