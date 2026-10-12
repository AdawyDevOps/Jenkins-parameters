variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}
