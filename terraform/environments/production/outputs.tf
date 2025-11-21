output "api_domain" {
  description = "API domain name"
  value       = module.bookstore_infrastructure.api_domain
}

output "api_url" {
  description = "API URL"
  value       = module.bookstore_infrastructure.api_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.bookstore_infrastructure.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.bookstore_infrastructure.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.bookstore_infrastructure.ecs_service_name
}

output "lambda_function_name" {
  description = "DNS updater Lambda function name"
  value       = module.bookstore_infrastructure.lambda_function_name
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.bookstore_infrastructure.ecr_repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.bookstore_infrastructure.ecr_repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.bookstore_infrastructure.rds_endpoint
  sensitive   = true
}

# ============================================================================
# GitHub OIDC Role Outputs
# ============================================================================

output "github_role_arn" {
  description = "ARN of the GitHub Actions IAM role - use this in your workflow"
  value       = module.github_deploy_role.role_arn
}

output "github_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = module.github_deploy_role.role_name
}

output "github_workflow_instructions" {
  description = "Instructions for using the role in GitHub Actions"
  value       = module.github_deploy_role.github_workflow_example
}

output "allowed_subject_patterns" {
  description = "OIDC subject patterns allowed to assume the GitHub role"
  value       = module.github_deploy_role.allowed_subject_patterns
}

output "terraform_state_path" {
  description = "S3 path used for Terraform state access"
  value       = module.github_deploy_role.terraform_state_path
}
