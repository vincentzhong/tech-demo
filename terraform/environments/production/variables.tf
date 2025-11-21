variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  # No default - must be specified in terraform.tfvars
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "api_subdomain" {
  description = "API subdomain"
  type        = string
  default     = "api"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "ecs_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "256"
}

variable "ecs_memory" {
  description = "ECS task memory in MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "use_spot" {
  description = "Use Fargate Spot for cost savings"
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Docker container image"
  type        = string
  default     = "nginx:latest"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ============================================================================
# GitHub OIDC Configuration
# ============================================================================

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (will be constructed dynamically if not provided)"
  type        = string
  default     = ""  # Will be constructed from aws_caller_identity if empty
}

# ============================================================================
# Terraform Backend Configuration (for state access)
# ============================================================================

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state (from bootstrap)"
  type        = string
}

variable "terraform_lock_table" {
  description = "DynamoDB table for state locking (from bootstrap)"
  type        = string
}
