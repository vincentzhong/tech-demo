output "role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_deploy.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.github_deploy.name
}

output "role_id" {
  description = "Unique ID of the IAM role"
  value       = aws_iam_role.github_deploy.unique_id
}

output "github_workflow_example" {
  description = "Example GitHub Actions workflow configuration"
  value       = <<-EOT
    # Add this to your GitHub Actions workflow:
    
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${aws_iam_role.github_deploy.arn}
          aws-region: us-east-1
      
      - name: Login to ECR
        run: |
          aws ecr get-login-password --region us-east-1 | \
            docker login --username AWS --password-stdin \
            $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
  EOT
}

output "allowed_subject_patterns" {
  description = "OIDC subject claim patterns that are allowed to assume this role"
  value       = local.all_subject_patterns
}

output "terraform_state_path" {
  description = "S3 path prefix used for Terraform state access"
  value       = var.allow_terraform_state_access ? "s3://${var.terraform_state_bucket}/${local.state_key_prefix}/*" : "N/A - Terraform state access not enabled"
}
