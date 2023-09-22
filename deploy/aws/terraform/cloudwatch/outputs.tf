output "cloudwatch-kms-key-arn" {
  value       = aws_kms_key.cloudwatch-kms-key.arn
  description = "The ARN of the CloudWatch KMS Key"
}
