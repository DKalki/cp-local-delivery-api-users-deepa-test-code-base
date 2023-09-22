variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "eu-west-2"
}

variable "backup_aws_region" {
  description = "The AWS region to back up the state resources into"
  default     = "eu-west-2"
}

variable "environment" {
  description = "Three letter abbreviation to describe the AWS account you are running in, e.g. sbx, dev, int, stg, prd"
  default     = ""
}

variable "cibuild_assumerole" {
  description = "Build IAM Role - passed via workspace tfvars at build time"
  default     = ""
}
