output "cognito-user-pool-id" {
  value = aws_cognito_user_pool.cp_ld_cognito_user_pool.id
}

output "cognito-user-pool-domain-cloudfront-distribution-arn" {
  value = aws_cognito_user_pool_domain.cp_ld_user_pool_domain.cloudfront_distribution_arn
}

output "cognito-scope-identifiers" {
  value = aws_cognito_resource_server.cp_ld_cognito_resource_server.scope_identifiers
}

output "cognito-user-pool-client-support-user-name" {
  value = aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_support_user.name
}

output "cognito-user-pool-client-support-user-id" {
  value = aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_support_user.id
}

output "cognito-user-pool-client-support-user-client-secret" {
  value = nonsensitive(aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_support_user.client_secret)
}

output "cognito-user-pool-client-patient-access-name" {
  value = aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_patient_access.name
}

output "cognito-user-pool-client-patient-access-id" {
  value = aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_patient_access.id
}

output "cognito-user-pool-client-support-patient-access-secret" {
  value = nonsensitive(aws_cognito_user_pool_client.cp_ld_cognito_user_pool_client_patient_access.client_secret)
}
