# ============================================================================
# Bootstrap Configuration
# ============================================================================
# This file contains ALL required parameters for the bootstrap module.
# Treat this as the "input parameters" to the bootstrap Terraform code.
# Copy this file for different projects/environments with different values.
# ============================================================================

# AWS Region
aws_region = "us-east-1"

# S3 bucket name (must be globally unique across ALL AWS accounts)
terraform_state_bucket = "tech-demo-terraform-state"

# DynamoDB table name
terraform_lock_table = "tech-demo-terraform-lock"

# ============================================================================
# Optional Resource Creation
# ============================================================================
# Set these to false if the resources already exist in your AWS account

# S3 bucket for Terraform state
create_s3_bucket = true

# DynamoDB table for state locking
create_dynamodb_table = true

# GitHub OIDC provider
create_oidc_provider = false

# ============================================================================
# Usage Notes
# ============================================================================
# If any resource already exists, set the corresponding flag to false.
# Bootstrap will reference the existing resource instead of creating it.
#
# To check if resources exist:
#   S3:       aws s3 ls | grep terraform-state
#   DynamoDB: aws dynamodb list-tables | grep terraform
#   OIDC:     aws iam list-open-id-connect-providers | grep github
