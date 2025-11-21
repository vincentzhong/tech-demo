# ============================================================================
# Bootstrap Infrastructure
# ============================================================================
# This Terraform configuration sets up the foundational AWS resources needed
# for all other Terraform projects:
# 
# 1. S3 bucket for remote state storage (with versioning & encryption)
# 2. DynamoDB table for state locking
# 3. GitHub OIDC provider for CI/CD authentication
#
# These resources are shared across ALL projects and only need to be created once.
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NOTE: Bootstrap uses LOCAL state (no S3 backend)
  # This is intentional - we're creating the S3 bucket here!
  # After initial apply, you can optionally migrate this state to S3
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = "bootstrap"
      Project     = "shared-infrastructure"
    }
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ============================================================================
# S3 Bucket for Terraform State
# ============================================================================

resource "aws_s3_bucket" "terraform_state" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = var.terraform_state_bucket

  lifecycle {
    prevent_destroy = true # Protect against accidental deletion
  }

  tags = {
    Name        = "Terraform Remote State Storage"
    Description = "Stores Terraform state files for all projects"
  }
}

# Data source to reference existing S3 bucket if not creating one
data "aws_s3_bucket" "terraform_state_existing" {
  count = var.create_s3_bucket ? 0 : 1
  
  bucket = var.terraform_state_bucket
}

# Enable versioning to track state history
resource "aws_s3_bucket_versioning" "terraform_state" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# DynamoDB Table for State Locking
# ============================================================================

resource "aws_dynamodb_table" "terraform_lock" {
  count = var.create_dynamodb_table ? 1 : 0

  name         = var.terraform_lock_table
  billing_mode = "PAY_PER_REQUEST" # On-demand pricing (cost-effective)
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true # Protect against accidental deletion
  }

  tags = {
    Name        = "Terraform State Lock"
    Description = "Prevents concurrent Terraform executions"
  }
}

# Data source to reference existing DynamoDB table if not creating one
data "aws_dynamodb_table" "terraform_lock_existing" {
  count = var.create_dynamodb_table ? 0 : 1
  
  name = var.terraform_lock_table
}

# ============================================================================
# GitHub OIDC Provider
# ============================================================================
# This enables GitHub Actions to authenticate with AWS without storing
# long-lived credentials. One OIDC provider per AWS account.
# 
# If you already have a GitHub OIDC provider, set create_oidc_provider = false
# in terraform.tfvars and import the existing provider:
#   terraform import aws_iam_openid_connect_provider.github[0] <arn>
# ============================================================================

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub's thumbprint (verified as of 2024)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd" # Backup thumbprint
  ]

  tags = {
    Name        = "GitHub Actions OIDC Provider"
    Description = "Allows GitHub Actions to assume IAM roles"
  }
}

# Data source to reference existing OIDC provider if not creating one
data "aws_iam_openid_connect_provider" "github_existing" {
  count = var.create_oidc_provider ? 0 : 1
  
  url = "https://token.actions.githubusercontent.com"
}

# ============================================================================
# Outputs
# ============================================================================

output "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state"
  value       = var.create_s3_bucket ? aws_s3_bucket.terraform_state[0].id : data.aws_s3_bucket.terraform_state_existing[0].id
}

output "terraform_lock_table" {
  description = "DynamoDB table name for state locking"
  value       = var.create_dynamodb_table ? aws_dynamodb_table.terraform_lock[0].id : data.aws_dynamodb_table.terraform_lock_existing[0].id
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github_existing[0].arn
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
    ✅ Bootstrap Complete!
    
    Next Steps:
    1. Note the S3 bucket name: ${var.create_s3_bucket ? aws_s3_bucket.terraform_state[0].id : data.aws_s3_bucket.terraform_state_existing[0].id}
    2. Note the DynamoDB table: ${var.create_dynamodb_table ? aws_dynamodb_table.terraform_lock[0].id : data.aws_dynamodb_table.terraform_lock_existing[0].id}
    3. Note the OIDC provider ARN: ${var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github_existing[0].arn}
    
    For each new project:
    - Use the github-oidc-role module to create a deployment role
    - Configure backend.hcl to use the S3 bucket and DynamoDB table above
    
    Example backend.hcl:
    bucket         = "${var.create_s3_bucket ? aws_s3_bucket.terraform_state[0].id : data.aws_s3_bucket.terraform_state_existing[0].id}"
    key            = "project-name/terraform.tfstate"
    region         = "${var.aws_region}"
    encrypt        = true
    dynamodb_table = "${var.create_dynamodb_table ? aws_dynamodb_table.terraform_lock[0].id : data.aws_dynamodb_table.terraform_lock_existing[0].id}"
  EOT
}
