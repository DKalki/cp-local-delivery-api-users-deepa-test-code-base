variable "instance" {
  description = "Instance name to identify AWS resources. This allows us to spin up many 'instances' of this service"
  default     = "main"
}

variable "environment" {
  description = "Three letter abbreviation to describe the AWS account you are running in, e.g. sbx, dev, int, stg, prd"
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "eu-west-2"
}

variable "account-id" {
  description = "The AWS account id that the resources are deployed to"
}

variable "default-tags" {
  description = "The AWS resource default tags"
  type        = map(string)
}

variable "audit-external-id" {
  description = "The ID to be used for the audit system"
}

variable "logging-external-id" {
  description = "The ID to be used for the logging system"
}
