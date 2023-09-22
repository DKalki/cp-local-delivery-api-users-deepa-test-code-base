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

variable "elb-account-id" {
  description = "The ELB account id" //https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "The availability zones attached to the vpc"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "public_subnets" {
  description = "The CIDRs for the public subnets attached to the VPC"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_subnets" {
  description = "The CIDRs for the private subnets attached to the VPC"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "database_subnets" {
  description = "The CIDRs for the database subnets attached to the VPC"
  type        = list(string)
  default     = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]
}

variable "hosted-zone-name" {
  description = "The name of the hosted zone"
  type        = string
}

variable "enable-deletion-protection" {
  description = "Enable deletion protection"
  type        = bool
}

variable "access-logs-enabled" {
  description = "Enable access logs"
  type        = bool
}

variable "access-logs-bucket" {
  description = "Access logs bucket"
  type        = string
}

variable "drop-invalid-header-fields" {
  description = "Drop invalid header fields"
  type        = bool
}

variable "rate-limit-default-action" {
  description = "Default action for rate limit WAF rule"
  type        = string
}

variable "rate-limit" {
  description = "The rate limit for the WAF rule (per 5 mins)"
  type        = string
}

variable "default-tags" {
  description = "The AWS resource default tags"
  type        = map(string)
}

variable "ld-api-country-codes" {
  description = "The country codes allowed to call the org management API"
  type        = list(string)
}

variable "subject-alternative-names" {
  description = "The subject alternative names for route 53"
  type        = list(string)
}
