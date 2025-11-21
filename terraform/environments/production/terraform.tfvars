# Bookstore API - Production Environment Configuration

# Project Configuration
project_name = "tech-demo"  # Used for resource naming (e.g., tech-demo-production-cluster)

# Domain Configuration
domain_name   = "zhong.nz"
api_subdomain = "api"

# Database Configuration (RDS MySQL t4g.micro - Free Tier Eligible)
db_instance_class    = "db.t4g.micro"
db_allocated_storage = 20
db_multi_az          = false

# ECS Configuration (Fargate Spot for cost savings)
ecs_cpu           = "256"   # 0.25 vCPU
ecs_memory        = "512"   # 0.5 GB
ecs_desired_count = 1
use_spot          = true

# Container Image (will be updated by CI/CD)
container_image = "nginx:latest"

# ============================================================================
# Secrets Management
# ============================================================================
# Sensitive variables should NEVER be in this file!
# Provide them via environment variables or GitHub Secrets:
#
# Local development:
#   PowerShell: $env:TF_VAR_db_password = "YourSecurePassword123!"
#   Bash:       export TF_VAR_db_password="YourSecurePassword123!"
#
# CI/CD (GitHub Actions):
#   Set DB_PASSWORD in GitHub Secrets, then workflow uses:
#   env:
#     TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
# ============================================================================

# ============================================================================
# GitHub OIDC Configuration
# ============================================================================

github_org  = "vincentzhong"
github_repo = "tech-demo"

# Optional: Customize the IAM role name (if not specified, defaults to github-deploy-{project}-{environment})
# role_name = "GithubDeploy-TechDemo-Bookstore-Prod"
# role_name = "github-deploy-techdemo-bookstore-production"  # Match state key pattern

# Get these values from bootstrap outputs:
# cd ../../bootstrap && terraform output
# Note: github_oidc_provider_arn is now constructed dynamically from AWS account ID
terraform_state_bucket = "tech-demo-terraform-state" 
terraform_lock_table   = "tech-demo-terraform-lock"
