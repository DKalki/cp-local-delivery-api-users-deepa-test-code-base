locals {
  name_prefix = var.instance
  cognito_user_pool_name = "${local.name_prefix}-ld-cognito-user-pool"
  cognito_user_pool_domain_name = "${local.name_prefix}-cp-ld"
  cognito_user_pool_client_name_support_user = "support-user"
  cognito_user_pool_client_name_patient_access = "patient-access"
  resource_server_name = "${local.name_prefix}-ld-resource-server"
}
