output "sqs-psc-kms-key-arn" {
  value = aws_kms_key.sqs_psc_encrypt.arn
}

output "sqs-external-kms-key-arn" {
  value = aws_kms_key.sqs_external_encrypt.arn
}

output "sns-kms-key-arn" {
  value = aws_kms_key.sns_encrypt.arn
}
