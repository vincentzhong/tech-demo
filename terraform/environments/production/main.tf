terraform {
  required_version = ">= 1.6.0"  # Updated to fix validation block issues
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration for production environment
    # These values must match what you created in bootstrap!
    bucket         = "tech-demo-terraform-state"      # From bootstrap
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tech-demo-terraform-lock"       # From bootstrap
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

# Additional provider for ACM certificate (CloudFront requires us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

# Get current AWS account info
data "aws_caller_identity" "current" {}

# Construct OIDC provider ARN dynamically if not provided
locals {
  github_oidc_provider_arn = var.github_oidc_provider_arn != "" ? var.github_oidc_provider_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# ============================================================================
# GitHub OIDC Role for CI/CD
# ============================================================================

module "github_deploy_role" {
  source = "../../modules/github-oidc-role"

  project_name  = var.project_name
  environment   = "production"
  
  # Optional: Customize role name to match your naming convention
  # role_name = "GithubDeploy-TechDemo-Bookstore-Prod"
  # If not specified, defaults to: github-deploy-bookstore-production
  
  github_org    = var.github_org
  github_repo   = var.github_repo
  github_branch = "main"

  # OIDC provider ARN (constructed dynamically from current AWS account)
  oidc_provider_arn = local.github_oidc_provider_arn

  # Enable Terraform state access for infrastructure deployments
  allow_terraform_state_access = true
  terraform_state_bucket       = var.terraform_state_bucket
  terraform_lock_table         = var.terraform_lock_table

  # For full infrastructure management, enable this:
  allow_full_terraform_permissions = true
}

# ============================================================================
# Application Infrastructure
# ============================================================================

# Use the shared infrastructure module
module "bookstore_infrastructure" {
  source = "../../modules/bookstore-infrastructure"

  # Pass providers to module
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  # Core configuration
  project_name = var.project_name
  environment  = "production"
  aws_region   = var.aws_region

  # Domain configuration
  domain_name   = var.domain_name
  api_subdomain = var.api_subdomain

  # Database configuration
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_multi_az          = var.db_multi_az

  # ECS configuration
  ecs_cpu           = var.ecs_cpu
  ecs_memory        = var.ecs_memory
  ecs_desired_count = var.ecs_desired_count
  use_spot          = var.use_spot

  # Container image (will be updated by CI/CD)
  container_image = var.container_image

  # Availability zones
  availability_zones = var.availability_zones
}
