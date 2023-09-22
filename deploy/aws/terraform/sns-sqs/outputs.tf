output "proscript-connect-source-queue-arn" {
  value = aws_sqs_queue.proscript_connect_source_queue.arn
}

output "proscript-connect-dead-letter-queue-arn" {
  value = aws_sqs_queue.proscript_connect_dead_letter_queue.arn
}

output "external-source-queue-arn" {
  value = aws_sqs_queue.external_source_queue.arn
}

output "external-dead-letter-queue-arn" {
  value = aws_sqs_queue.external_dead_letter_queue.arn
}

output "sns-queue-arn" {
  value = aws_sns_topic.sns_topic.arn
}