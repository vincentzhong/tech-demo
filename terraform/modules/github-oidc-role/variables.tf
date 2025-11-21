variable "project_name" {
  description = "Name of the project (e.g., 'bookstore', 'inventory')"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "role_name" {
  description = "Custom IAM role name. If empty, defaults to 'github-deploy-{project_name}-{environment}'"
  type        = string
  default     = ""

  validation {
    condition     = var.role_name == "" || can(regex("^[a-zA-Z0-9-_+=,.@]+$", var.role_name))
    error_message = "Role name must match IAM role naming requirements."
  }
}

variable "environment" {
  description = "Environment name (e.g., 'production', 'staging', 'dev')"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "dev", "test"], var.environment)
    error_message = "Environment must be one of: production, staging, dev, test."
  }
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch that can assume this role. Set to '*' to allow all branches (when using only environment-based restrictions)"
  type        = string
  default     = "main"
}

variable "additional_subject_patterns" {
  description = "Additional subject claim patterns for OIDC trust policy. Useful for supporting multiple branch patterns or custom claims"
  type        = list(string)
  default     = []
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (created in bootstrap)"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:oidc-provider/token.actions.githubusercontent.com$", var.oidc_provider_arn))
    error_message = "Must be a valid GitHub OIDC provider ARN."
  }
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (1-12 hours)"
  type        = number
  default     = 3600 # 1 hour

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Session duration must be between 3600 (1 hour) and 43200 (12 hours)."
  }
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON. If empty, uses default ECS/ECR deployment permissions"
  type        = string
  default     = ""
}

variable "allow_terraform_state_access" {
  description = "Grant permissions to read/write Terraform state in S3 and DynamoDB"
  type        = bool
  default     = false
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state (required if allow_terraform_state_access = true)"
  type        = string
  default     = ""
}

variable "terraform_lock_table" {
  description = "DynamoDB table for state locking (required if allow_terraform_state_access = true)"
  type        = string
  default     = ""
}

variable "terraform_state_key_prefix" {
  description = "S3 key prefix for Terraform state. Use 'environment' (default) for environment-based paths, 'project' for project-based paths, or a custom prefix"
  type        = string
  default     = "environment"
}

variable "allow_full_terraform_permissions" {
  description = "Attach PowerUserAccess policy for full Terraform operations (use cautiously)"
  type        = bool
  default     = false
}
