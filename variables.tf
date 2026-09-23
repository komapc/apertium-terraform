variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "create_s3_bucket" {
  description = "Create S3 bucket for extractor results"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ido-epo-translator"
}
