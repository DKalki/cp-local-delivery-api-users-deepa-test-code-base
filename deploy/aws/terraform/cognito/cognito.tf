resource "aws_cognito_user_pool" "cp_ld_cognito_user_pool" {
  name = local.cognito_user_pool_name

    account_recovery_setting {
        recovery_mechanism {
        name     = "verified_email"
        priority = 1
        }
    }
  tags = var.default-tags
}

resource "aws_cognito_user_pool_domain" "cp_ld_user_pool_domain" {
  domain       = local.cognito_user_pool_domain_name
  user_pool_id = aws_cognito_user_pool.cp_ld_cognito_user_pool.id
}

resource "aws_cognito_resource_server" "cp_ld_cognito_resource_server" {
  identifier = local.resource_server_name
  name       = local.resource_server_name

  scope {
    scope_name        = "read"
    scope_description = "for calling the Get API"
  }

  scope {
    scope_name        = "write"
    scope_description = "for calling the Post API"
  }

  user_pool_id = aws_cognito_user_pool.cp_ld_cognito_user_pool.id
}

resource "aws_cognito_user_pool_client" "cp_ld_cognito_user_pool_client_support_user" {
  name                                 = local.cognito_user_pool_client_name_support_user
  user_pool_id                         = aws_cognito_user_pool.cp_ld_cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = [for scope in aws_cognito_resource_server.cp_ld_cognito_resource_server.scope_identifiers: scope if scope == "sbx-ld-resource-server/read" || scope == "sbx-ld-resource-server/write"]


  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = true

  prevent_user_existence_errors = "ENABLED"

  refresh_token_validity = 30

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_client" "cp_ld_cognito_user_pool_client_patient_access" {
  name                                 = local.cognito_user_pool_client_name_patient_access
  user_pool_id                         = aws_cognito_user_pool.cp_ld_cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = [for scope in aws_cognito_resource_server.cp_ld_cognito_resource_server.scope_identifiers: scope if scope == "sbx-ld-resource-server/write"]


  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = true

  prevent_user_existence_errors = "ENABLED"

  refresh_token_validity = 30

  supported_identity_providers = ["COGNITO"]
}