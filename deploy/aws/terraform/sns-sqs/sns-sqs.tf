data "aws_kms_alias" "kms_key_alias_psc" {
  name = "alias/${var.instance}-ld-stor-kk-sqs-psc"
}

data "aws_kms_alias" "kms_key_alias_external" {
  name = "alias/${var.instance}-ld-stor-kk-sqs-external"
}

data "aws_kms_alias" "kms_key_alias_sns" {
  name = "alias/${var.instance}-ld-stor-kk-sns"
}

resource "aws_sqs_queue" "proscript_connect_dead_letter_queue" {
  name                      = "${var.instance}-ld-sqs-psc-dq"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  kms_master_key_id         = data.aws_kms_alias.kms_key_alias_psc.target_key_arn
  tags = var.default-tags
}

resource "aws_sqs_queue" "proscript_connect_source_queue" {
  name                      = "${var.instance}-ld-sqs-psc-sq"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  kms_master_key_id         = data.aws_kms_alias.kms_key_alias_psc.target_key_arn
  policy = templatefile(
    "${path.module}/templates/iam_policies/psc-sqs-policy.tpl",
    {
      aws-region = var.aws_region
      account-id = var.account-id
      instance   = var.instance
    })
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.proscript_connect_dead_letter_queue.arn
    maxReceiveCount     = 4
  })
  tags = var.default-tags
}

resource "aws_sqs_queue" "external_dead_letter_queue" {
  name                      = "${var.instance}-ld-sqs-external-dq"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  kms_master_key_id         = data.aws_kms_alias.kms_key_alias_external.target_key_arn
  tags = var.default-tags
}

resource "aws_sqs_queue" "external_source_queue" {
  name                      = "${var.instance}-ld-sqs-external-sq"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 10
  kms_master_key_id         = data.aws_kms_alias.kms_key_alias_external.target_key_arn
  policy = templatefile(
    "${path.module}/templates/iam_policies/external-sqs-policy.tpl",
    {
      aws-region = var.aws_region
      account-id = var.account-id
      instance   = var.instance      
    })
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.external_dead_letter_queue.arn
    maxReceiveCount     = 4
  })
  tags = var.default-tags
}

resource "aws_sns_topic" "sns_topic" {
  name              = "${var.instance}-ld-sns-psc"
  kms_master_key_id = data.aws_kms_alias.kms_key_alias_sns.target_key_arn
  tags = var.default-tags
}

resource "aws_sns_topic_subscription" "psc_sqs_target" {
  topic_arn           = aws_sns_topic.sns_topic.arn
  protocol            = "sqs"
  endpoint            = aws_sqs_queue.proscript_connect_source_queue.arn
  raw_message_delivery= true
  filter_policy       = jsonencode({
    source = ["psc"]
  })
  filter_policy_scope = "MessageAttributes"
}

resource "aws_sns_topic_subscription" "external_sqs_target" {
  topic_arn           = aws_sns_topic.sns_topic.arn
  protocol            = "sqs"
  endpoint            = aws_sqs_queue.external_source_queue.arn
  raw_message_delivery= true
  filter_policy       = jsonencode({
    source = [
      {
        "anything-but" = "psc"
      }
    ]
  })
  filter_policy_scope = "MessageAttributes"
}