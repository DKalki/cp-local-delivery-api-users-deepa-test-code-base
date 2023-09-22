locals {
  environment = get_env("ENV", "")
  instance    = get_env("INSTANCE", "")
  aws_region  = get_env("AWS_REGION", "eu-west-2")
  ci          = get_env("CI", "false")

  # State file values
  state_bucket     = "${local.environment}-ld-stor-s3-terraformstate"
  state_lock_table = "${local.environment}-ld-stor-dyt-terraformstate"

  # Use terragrunt built in functions to supply common used values
  caller_user_id = get_aws_caller_identity_user_id()
}

# Export TG vars as TF input vars
inputs = {
  environment    = local.environment
  aws_region     = local.aws_region
  instance       = local.instance
  ci             = local.ci
  caller_user_id = local.caller_user_id
}

# Dynamically provision the remote state
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.state_bucket
    dynamodb_table = local.state_lock_table
    encrypt        = true
    key            = "env:/${local.environment}/${local.instance}/${path_relative_to_include()}.tfstate"
    region         = local.aws_region
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.grunt.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.53"
      }
    }
    required_version = ">= 0.14.9"
  }

  provider "aws" {
    region = var.aws_region
  }
EOF
}

# Additional Terraform commands, config and pre/post hooks
terraform {
  # Always remove the .terraform dir before running init
  before_hook "before_init" {
    commands = ["init"]
    execute  = ["rm", "-rf", "./.terraform"]
  }

  # Terragrunt auto-init isn't always reliable - run init regardless
  before_hook "init_submodule" {
    commands = ["validate", "plan", "apply", "destroy", "workspace", "output", "import"]
    execute  = ["terraform", "init"]
  }
}
