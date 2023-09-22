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
  description = "AWS account ID"
  type        = string
}

variable "default-tags" {
  description = "The AWS resource default tags"
  type        = map(string)
}
