include {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "module_tf_vars_files" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "${get_env("TF_PROMPT","-input=true")}",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/common.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/alb.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/vpc.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/hosted-zone.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/waf.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/configuration/${get_env("ENV", "ENV_NOT_SET")}/certificate.tfvars"
    ]
  }
}
