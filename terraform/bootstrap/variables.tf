variable "aws_region" {
  description = "AWS region for bootstrap resources"
  type        = string
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state (must be globally unique)"
  type        = string
}

variable "terraform_lock_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

# ============================================================================
# Optional Resource Creation Flags
# ============================================================================

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket. Set to false if it already exists."
  type        = bool
}

variable "create_dynamodb_table" {
  description = "Whether to create the DynamoDB table. Set to false if it already exists."
  type        = bool
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider. Set to false if it already exists in your AWS account."
  type        = bool
}
