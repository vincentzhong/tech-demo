# ============================================================================
# GitHub OIDC IAM Role Module
# ============================================================================
# Creates an IAM role that GitHub Actions can assume via OIDC authentication.
# This eliminates the need for long-lived AWS credentials in GitHub secrets.
# 
# Usage:
#   module "github_role" {
#     source = "../../modules/github-oidc-role"
#     
#     project_name       = "bookstore"
#     github_org         = "your-org"
#     github_repo        = "TechDemo"
#     github_branch      = "main"
#     oidc_provider_arn  = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
#     
#     # Customize permissions for this project
#     custom_policy_json = jsonencode({...})
#   }
# ============================================================================

terraform {
  required_version = ">= 1.6.0"  # Updated to fix validation block issues

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Get current AWS account details
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# Build OIDC Subject Patterns
# ============================================================================
# Supports both branch-based and environment-based GitHub Actions workflows
# This ensures the role works whether you use GitHub environments or not

locals {
  # Base subject patterns that always work
  base_subject_patterns = [
    # Branch-based: repo:org/repo:ref:refs/heads/main
    "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}",
    # Environment-based: repo:org/repo:environment:production
    "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}",
  ]

  # Combine base patterns with any additional custom patterns
  all_subject_patterns = concat(
    local.base_subject_patterns,
    var.additional_subject_patterns
  )

  # Determine S3 state path based on strategy
  state_key_prefix = var.terraform_state_key_prefix == "environment" ? var.environment : (
    var.terraform_state_key_prefix == "project" ? var.project_name : var.terraform_state_key_prefix
  )
}

# ============================================================================
# IAM Role for GitHub Actions
# ============================================================================

resource "aws_iam_role" "github_deploy" {
  name        = var.role_name != "" ? var.role_name : "github-deploy-${var.project_name}-${var.environment}"
  description = "Role for GitHub Actions to deploy ${var.project_name} (${var.environment})"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Automatically supports both branch-based and environment-based workflows
            # This ensures the role works whether you use GitHub environments or not
            "token.actions.githubusercontent.com:sub" = local.all_subject_patterns
          }
        }
      }
    ]
  })

  max_session_duration = var.max_session_duration

  tags = {
    Name        = "github-deploy-${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    GitHubRepo  = "${var.github_org}/${var.github_repo}"
  }
}

# ============================================================================
# IAM Policy for Deployment Permissions
# ============================================================================

resource "aws_iam_role_policy" "deploy_permissions" {
  name = "${var.project_name}-${var.environment}-deploy-policy"
  role = aws_iam_role.github_deploy.id

  policy = var.custom_policy_json != "" ? var.custom_policy_json : data.aws_iam_policy_document.default_permissions.json
}

# Default permissions if no custom policy provided
data "aws_iam_policy_document" "default_permissions" {
  # ECR - Push Docker images
  statement {
    sid    = "ECRPermissions"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }

  # ECS - Deploy new task definitions and update services
  statement {
    sid    = "ECSDeployPermissions"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:RunTask"
    ]
    resources = ["*"]
  }

  # IAM - Pass role to ECS tasks
  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  # CloudWatch Logs - View deployment logs
  statement {
    sid    = "CloudWatchLogsRead"
    effect = "Allow"
    actions = [
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

# ============================================================================
# Optional: Terraform State Access (if this role manages infrastructure)
# ============================================================================

resource "aws_iam_role_policy" "terraform_state_access" {
  count = var.allow_terraform_state_access ? 1 : 0

  name = "${var.project_name}-${var.environment}-terraform-state-access"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        # Flexible S3 path based on terraform_state_key_prefix variable
        # Defaults to environment-based (production/*) but can use project-based or custom
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}/${local.state_key_prefix}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.terraform_lock_table}"
      }
    ]
  })
}

# ============================================================================
# Optional: Full Infrastructure Permissions (for Terraform apply)
# ============================================================================

resource "aws_iam_role_policy_attachment" "full_terraform_permissions" {
  count = var.allow_full_terraform_permissions ? 1 : 0

  role       = aws_iam_role.github_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Additional IAM read permissions for Terraform state refresh
# PowerUserAccess doesn't include IAM read permissions, but Terraform needs them
resource "aws_iam_role_policy" "iam_read_permissions" {
  count = var.allow_full_terraform_permissions ? 1 : 0

  name = "${var.project_name}-${var.environment}-iam-read-policy"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:GetInstanceProfile",
          "iam:GetOpenIDConnectProvider",
          "iam:ListInstanceProfilesForRole"
        ]
        Resource = "*"
      }
    ]
  })
}
