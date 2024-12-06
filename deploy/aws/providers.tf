# contains all provider blocks and configuration

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

provider "aws" {
  region = var.aws_region
}
