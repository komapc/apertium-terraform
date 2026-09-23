terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# NOTE: the production APy server is NOT managed here.
# It was created out-of-band (i-056c20a3f393e9982, t3.micro, eu-west-1, no EIP)
# and is not in terraform state. The previous aws_instance/aws_eip/
# aws_security_group/aws_key_pair definitions were removed (their resources were
# destroyed on 2026-08-21) so that `terraform apply` can no longer create a
# second, duplicate server. This configuration manages only the S3 bucket (s3.tf).
