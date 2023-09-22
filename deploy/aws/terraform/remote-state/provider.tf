provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.cibuild_assumerole
    session_name = "TerraformBuild"
  }
}

provider "aws" {
  alias  = "backup"
  region = var.backup_aws_region

  assume_role {
    role_arn     = var.cibuild_assumerole
    session_name = "TerraformBuild"
  }
}
