output "paramstore-kms-key-arn" {
  value       = aws_kms_key.kms-key.key_id
  description = "The ARN of the KMS Key"
}
