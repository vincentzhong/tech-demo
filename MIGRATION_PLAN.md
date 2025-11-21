# AWS Account Migration & Git History Cleanup Plan

**Project**: Full-Stack Bookstore Application  
**Current Status**: Running on AWS (app.zhong.nz + api.zhong.nz)  
**Goal**: Migrate to new AWS account (fresh free tier) + Clean Git history  
**Estimated Time**: 6-8 hours over 2-3 days  
**Cost Savings**: $240-336 over 12 months

---

## 📋 EXECUTIVE SUMMARY

### Problems to Solve
1. **AWS Free Tier Expiring** → Will cost $20-28/month after expiration
2. **Sensitive Data in Git History** → Potential security risk for portfolio project

### ⚠️ IMPORTANT: AWS Free Tier Changed July 15, 2025

**OLD MODEL (Before July 15, 2025):**
- 12-month free tier for new accounts
- Always-free services continue indefinitely
- Account doesn't auto-close after 12 months

**NEW MODEL (After July 15, 2025):**
- **6-month Free Plan** with $100-200 in credits (not 12 months!)
- Credits expire after 6 months OR when depleted
- Account **auto-closes** after expiry (90-day grace period)
- Must upgrade to "Paid Plan" to keep account active
- Always-free services still available on Paid Plan

### Recommended Solution
**Option A: New AWS Account + Clean Git History** ⚠️ **WITH CAVEATS**

**Why This Approach:**
- ✅ Get $100-200 in AWS credits (6 months)
- ✅ Completely removes sensitive data from Git history
- ✅ Keeps same GitHub repo URL (CV stays valid)
- ✅ Shows clean, production-ready code to employers
- ✅ Mostly automated via existing CI/CD pipeline

**⚠️ CRITICAL CAVEAT:**
- **Only 6 months free** (not 12 months anymore)
- **Must upgrade to Paid Plan** after 6 months to keep account
- **Paid Plan still has always-free services** (Lambda, DynamoDB, S3, CloudFront limits)
- **Your architecture fits within always-free limits** (~$1/month for Route 53 only)

**Alternative Considered:**
- Keep current AWS account + pay $20-28/month (rejected - unnecessary cost)
- Move to cheaper cloud provider (rejected - AWS more impressive for portfolio)
- BFG Repo-Cleaner for selective history cleaning (rejected - too complex, might miss data)
- Oracle Cloud Always Free (considered - see Alternative Options section)

---

## 🎯 MIGRATION STRATEGY OVERVIEW

### High-Level Steps
1. **Prepare New AWS Account** (30 min)
2. **Clean Git History** (1-2 hours)
3. **Update Configuration** (1 hour)
4. **Deploy to New AWS Account** (1-2 hours)
5. **Update Vercel** (15 min)
6. **Cleanup Old AWS Account** (30 min)
7. **Verification & Testing** (1-2 hours)

### Key Principle
**Leverage existing automation** - Your Terraform + GitHub Actions CI/CD will do most of the heavy lifting. You're essentially "replaying" your infrastructure setup in a new AWS account.

---

## 📝 DETAILED STEP-BY-STEP PLAN

## PHASE 1: PREPARE NEW AWS ACCOUNT (30 minutes)

### 1.1 Create New AWS Account
**Action:**
```
1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Use a different email address (e.g., yourname+aws2@gmail.com)
   - Gmail tip: yourname+anything@gmail.com goes to yourname@gmail.com
4. Complete account setup
5. Verify email and phone number
6. Add payment method (required for free tier)
```

**Expected Result:**
- New AWS account with fresh 12-month free tier
- Root user credentials saved securely

**Notes:**
- Free tier includes: 750 hours/month RDS, 750 hours/month Fargate, 50GB CloudFront data transfer
- Your current architecture fits within free tier limits

### 1.2 Create IAM User for Local Access
**Action:**
```bash
# In new AWS account console:
1. Go to IAM → Users → Create User
2. Username: "terraform-admin" (or your preference)
3. Enable "Provide user access to AWS Management Console"
4. Attach policy: AdministratorAccess (for initial setup)
5. Create user
6. Download credentials CSV
7. Configure AWS CLI locally:

aws configure --profile new-aws-account
# Enter:
# - AWS Access Key ID: [from CSV]
# - AWS Secret Access Key: [from CSV]
# - Default region: us-east-1
# - Default output format: json
```

**Expected Result:**
- IAM user with admin access
- AWS CLI configured with new profile

### 1.3 Bootstrap New AWS Account (Terraform State + OIDC)
**Action:**
```bash
cd terraform/bootstrap

# Update terraform.tfvars for new account
# Change S3 bucket name (must be globally unique)
# Example: tech-demo-terraform-state → tech-demo-terraform-state-2024

# Apply bootstrap (creates S3, DynamoDB, OIDC provider)
terraform init
terraform plan
terraform apply

# Save outputs - you'll need these later
terraform output
```

**Files to Update:**
- `terraform/bootstrap/terraform.tfvars`:
  ```hcl
  terraform_state_bucket = "tech-demo-terraform-state-2024"  # Must be unique
  terraform_lock_table   = "tech-demo-terraform-lock"
  create_s3_bucket       = true
  create_dynamodb_table  = true
  create_oidc_provider   = true  # Change from false to true
  ```

**Expected Result:**
- S3 bucket for Terraform state: `tech-demo-terraform-state-2024`
- DynamoDB table for state locking: `tech-demo-terraform-lock`
- GitHub OIDC provider ARN: `arn:aws:iam::<NEW_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com`

**Critical:** Save the Terraform outputs - you need them for next steps!

---

## PHASE 2: CLEAN GIT HISTORY (1-2 hours)

### 2.1 Backup Current Repository
**Action:**
```bash
cd c:\Development\Projects
cp -r TechDemo TechDemo-backup-$(Get-Date -Format "yyyy-MM-dd")

# Or on Windows PowerShell:
Copy-Item -Path TechDemo -Destination "TechDemo-backup-$(Get-Date -Format 'yyyy-MM-dd')" -Recurse
```

**Expected Result:**
- Full backup of current repository in `TechDemo-backup-2024-11-21` (or current date)

**Why:** Safety net in case something goes wrong during Git history rewrite

### 2.2 Export Current Database (Optional but Recommended)
**Action:**
```bash
# If you have production data you want to keep:
# Option 1: Use AWS Console
# RDS → Databases → Select your DB → Actions → Take snapshot

# Option 2: Use mysqldump (if you have data to preserve)
# Get RDS endpoint from Terraform outputs or AWS console
# mysqldump -h <rds-endpoint> -u admin -p Bookstore > bookstore-backup.sql
```

**Expected Result:**
- Database snapshot or SQL dump file

**Notes:**
- If this is just demo data, you can skip this
- Your migrations will recreate the schema automatically

### 2.3 Rewrite Git History (Single Clean Commit)
**Action:**
```bash
cd c:\Development\Projects\TechDemo

# Create orphan branch (fresh history with no parent commits)
git checkout --orphan clean-main

# Stage all current files
git add -A

# Create single initial commit with descriptive message
git commit -m "Initial commit: Full-stack bookstore application

- Frontend: React + TypeScript + Vite (deployed to Vercel)
- Backend: .NET 9 Web API (deployed to AWS ECS Fargate)
- Database: MySQL on AWS RDS
- Infrastructure: Terraform + GitHub Actions CI/CD
- Architecture: CloudFront CDN + Route 53 DNS + Lambda auto-updater
- Cost-optimized: ~$20/month (no ALB, Fargate Spot pricing)
- Security: JWT authentication, BCrypt password hashing
- Features: Books & Authors CRUD, user authentication, health checks"

# Delete old main branch locally
git branch -D main

# Rename clean-main to main
git branch -m main

# Force push to GitHub (THIS REWRITES HISTORY - CANNOT BE UNDONE)
git push -f origin main
```

**Expected Result:**
- Git history reduced to 1 commit
- All sensitive data removed from history
- Same repo URL: https://github.com/vincentzhong/tech-demo

**⚠️ CRITICAL WARNINGS:**
1. **This completely rewrites Git history** - anyone who cloned the repo must re-clone
2. **Cannot be undone** - make sure you have backup (step 2.1)
3. **All commit history will be lost** - only current state preserved
4. **GitHub Actions will trigger** - but will fail until you update secrets (Phase 3)

**Alternative (If You Want to Preserve Some History):**
If you want to keep recent commits but remove old sensitive ones:
```bash
# Find the commit where you want to start fresh history
git log --oneline

# Create new branch from that commit
git checkout -b clean-main <commit-hash>

# Force push
git push -f origin clean-main:main
```

---

## PHASE 3: UPDATE CONFIGURATION FOR NEW AWS ACCOUNT (1 hour)

### 3.1 Update Terraform Backend Configuration
**Action:**

**File: `terraform/environments/production/main.tf`**
```hcl
# Update lines 10-18:
backend "s3" {
  bucket         = "tech-demo-terraform-state-2024"  # ← NEW bucket name from Phase 1
  key            = "production/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "tech-demo-terraform-lock"
}
```

**File: `terraform/environments/production/terraform.tfvars`**
```hcl
# Update lines 54-55:
terraform_state_bucket = "tech-demo-terraform-state-2024"  # ← NEW bucket name
terraform_lock_table   = "tech-demo-terraform-lock"
```

**Expected Result:**
- Terraform will use new S3 bucket for state storage

### 3.2 Update GitHub Secrets
**Action:**
```
1. Go to: https://github.com/vincentzhong/tech-demo/settings/secrets/actions

2. Update these secrets:

   AWS_ROLE_TO_ASSUME:
   - Old: arn:aws:iam::<OLD_ACCOUNT_ID>:role/github-deploy-tech-demo-production
   - New: arn:aws:iam::<NEW_ACCOUNT_ID>:role/github-deploy-tech-demo-production

   DB_PASSWORD:
   - Keep same or change to new password
   - If changing, remember it for later steps

3. Verify these secrets exist (should not need changes):
   - VERCEL_TOKEN
   - VERCEL_ORG_ID
   - VERCEL_PROJECT_ID
```

**How to Get New AWS Account ID:**
```bash
# Using AWS CLI with new profile:
aws sts get-caller-identity --profile new-aws-account --query Account --output text

# Or in AWS Console:
# Click your username (top right) → Account ID is shown
```

**Expected Result:**
- GitHub Actions can authenticate with new AWS account
- Database password is set

**Note:** The IAM role doesn't exist yet - it will be created by Terraform in Phase 4

### 3.3 Update Domain Configuration (If Needed)

**Scenario A: Domain is in Route 53 in OLD AWS account**
```
Option 1: Transfer domain to new account
1. Old AWS Console → Route 53 → Registered Domains
2. Select zhong.nz → Transfer to another AWS account
3. Enter new AWS account ID
4. Accept transfer in new account

Option 2: Keep domain in old account, update NS records
1. Keep domain registration in old account
2. Create hosted zone in new account (Terraform will do this)
3. Update NS records in old account to point to new hosted zone
```

**Scenario B: Domain is with external registrar (e.g., Namecheap, GoDaddy)**
```
No action needed - Terraform will create Route 53 hosted zone
You'll update NS records at registrar after deployment (Phase 4)
```

**Expected Result:**
- Clear plan for domain DNS management

### 3.4 Commit Configuration Changes
**Action:**
```bash
git add terraform/environments/production/main.tf
git add terraform/environments/production/terraform.tfvars
git commit -m "chore: update Terraform backend for new AWS account"
git push origin main
```

**Expected Result:**
- Configuration changes committed to clean Git history
- GitHub Actions will trigger but may fail (expected - infrastructure doesn't exist yet)

---

## PHASE 4: DEPLOY TO NEW AWS ACCOUNT (1-2 hours)

### 4.1 Initial Terraform Deployment (Local)
**Action:**
```bash
cd terraform/environments/production

# Initialize Terraform with new backend
terraform init -reconfigure

# Plan deployment
terraform plan -var-file=terraform.tfvars -var="db_password=<YOUR_DB_PASSWORD>"

# Review the plan - should show creation of:
# - VPC, subnets, security groups
# - RDS MySQL instance
# - ECS cluster, task definition, service
# - ECR repository
# - CloudFront distribution
# - Route 53 records
# - Lambda function for DNS updates
# - IAM roles (including GitHub Actions role)

# Apply (this will take 10-15 minutes)
terraform apply -var-file=terraform.tfvars -var="db_password=<YOUR_DB_PASSWORD>"
```

**Expected Result:**
- All AWS infrastructure created in new account
- Terraform outputs show:
  - ECS cluster name
  - ECR repository URL
  - API domain: api.zhong.nz
  - GitHub role ARN

**Notes:**
- RDS creation takes ~10 minutes
- CloudFront distribution takes ~15 minutes to fully deploy
- ECS service will be in "unhealthy" state until you deploy the Docker image (next step)

### 4.2 Trigger CI/CD Pipeline
**Action:**
```bash
# Make a small change to trigger deployment
cd c:\Development\Projects\TechDemo

# Option 1: Empty commit
git commit --allow-empty -m "chore: trigger deployment to new AWS account"
git push origin main

# Option 2: Update a comment in code
# Edit BookstoreApi/Program.cs, add a comment, commit and push
```

**Expected Result:**
- GitHub Actions workflow starts
- Workflow will:
  1. Build .NET API
  2. Run Terraform (should show "no changes" since you just applied locally)
  3. Build Docker image
  4. Push to ECR in new account
  5. Update ECS service
  6. Run database migration
  7. Wait for service stability

**Monitor Progress:**
```
https://github.com/vincentzhong/tech-demo/actions
```

**Expected Duration:** 10-15 minutes

### 4.3 Verify Deployment
**Action:**
```bash
# Test API health endpoint
curl https://api.zhong.nz/health

# Expected response:
# {"status":"Healthy","database":"Healthy"}

# Test API endpoints
curl https://api.zhong.nz/api/books
curl https://api.zhong.nz/api/authors

# Check ECS service
aws ecs describe-services \
  --cluster tech-demo-production-cluster \
  --services tech-demo-production-service \
  --profile new-aws-account

# Check CloudFront distribution
aws cloudfront list-distributions \
  --query "DistributionList.Items[?Comment=='tech-demo production API'].{Id:Id,Status:Status,DomainName:DomainName}" \
  --profile new-aws-account
```

**Expected Result:**
- API responds with 200 OK
- ECS service shows "RUNNING" status
- CloudFront distribution shows "Deployed" status

**Troubleshooting:**
- If API returns 503: ECS tasks may still be starting (wait 2-3 minutes)
- If API returns 502: Check ECS task logs in CloudWatch
- If DNS doesn't resolve: Check Route 53 hosted zone NS records

---

## PHASE 5: UPDATE VERCEL (15 minutes)

### 5.1 Verify Vercel Environment Variables
**Action:**
```bash
cd bookstore-ui

# List current environment variables
npx vercel env ls

# Check if VITE_API_URL is set correctly
# Should be: https://api.zhong.nz
```

**Expected Result:**
- `VITE_API_URL` is already set to `https://api.zhong.nz`
- No changes needed (API URL hasn't changed)

**If Variable Needs Update:**
```bash
# Remove old value
npx vercel env rm VITE_API_URL production

# Add new value
npx vercel env add VITE_API_URL production
# When prompted, enter: https://api.zhong.nz

# Redeploy frontend
npx vercel --prod
```

### 5.2 Test Frontend
**Action:**
```
1. Open browser: https://app.zhong.nz
2. Verify:
   - Page loads without errors
   - Books list displays
   - Can view book details
   - Can login (if you have test user)
   - Can create/edit/delete books (after login)
3. Check browser console for errors (F12)
```

**Expected Result:**
- Frontend loads successfully
- API calls work (books/authors display)
- No CORS errors
- No mixed content warnings

**Troubleshooting:**
- If "Failed to fetch": Check VITE_API_URL environment variable
- If CORS error: Check ECS task is running and security groups allow traffic
- If 401 Unauthorized: JWT authentication working correctly (expected for protected endpoints)

---

## PHASE 6: CLEANUP OLD AWS ACCOUNT (30 minutes)

### 6.1 Export Any Important Data
**Action:**
```bash
# If you have production data in old account:
# 1. Export database (already done in Phase 2.2)
# 2. Download any CloudWatch logs you want to keep
# 3. Export any custom metrics or dashboards

# Check for any resources you might want to keep:
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=tech-demo \
  --profile old-aws-account
```

**Expected Result:**
- All important data backed up
- Clear list of resources to delete

### 6.2 Destroy Infrastructure in Old Account
**Action:**
```bash
cd terraform/environments/production

# Switch to old AWS account profile
export AWS_PROFILE=old-aws-account  # or set in PowerShell: $env:AWS_PROFILE="old-aws-account"

# IMPORTANT: Make sure you're in the OLD account
aws sts get-caller-identity

# Destroy all Terraform-managed resources
terraform destroy -var-file=terraform.tfvars -var="db_password=<OLD_DB_PASSWORD>"

# Confirm destruction when prompted
# This will delete:
# - ECS cluster and tasks
# - RDS database (⚠️ PERMANENT DATA LOSS)
# - CloudFront distribution
# - Route 53 records
# - Lambda functions
# - VPC and networking
# - IAM roles
```

**Expected Result:**
- All infrastructure destroyed in old account
- Terraform state shows no resources

**⚠️ CRITICAL WARNINGS:**
1. **This deletes your database** - make sure you have backup if needed
2. **Cannot be undone** - double-check you're in the OLD account
3. **Verify first**: `aws sts get-caller-identity` should show OLD account ID

### 6.3 Manual Cleanup (Resources Not Managed by Terraform)
**Action:**
```bash
# Delete ECR images (Terraform doesn't delete images)
aws ecr list-images \
  --repository-name tech-demo-production-api \
  --profile old-aws-account

aws ecr batch-delete-image \
  --repository-name tech-demo-production-api \
  --image-ids imageTag=production-<sha> \
  --profile old-aws-account

# Delete CloudWatch log groups (optional - they're cheap)
aws logs describe-log-groups \
  --log-group-name-prefix /ecs/tech-demo \
  --profile old-aws-account

aws logs delete-log-group \
  --log-group-name /ecs/tech-demo-production \
  --profile old-aws-account

# Delete S3 Terraform state bucket (if you want)
# ⚠️ Only do this if you're 100% sure you don't need the state
aws s3 rb s3://tech-demo-terraform-state --force --profile old-aws-account
```

**Expected Result:**
- All resources cleaned up
- Old AWS account has minimal/no resources

### 6.4 Close Old AWS Account (Optional)
**Action:**
```
1. Go to AWS Console (old account)
2. Click account name → Account
3. Scroll to "Close Account"
4. Follow prompts to close account

⚠️ ONLY DO THIS IF:
- You have no other resources in this account
- You've verified new account works perfectly
- You've waited at least 1 week to ensure stability
```

**Expected Result:**
- Old AWS account closed
- No future charges

**Recommendation:** Wait 1-2 weeks before closing old account, in case you need to reference something

---

## PHASE 7: VERIFICATION & TESTING (1-2 hours)

### 7.1 Comprehensive Testing Checklist

**Backend API Tests:**
```bash
# Health check
curl https://api.zhong.nz/health

# Get all books
curl https://api.zhong.nz/api/books

# Get all authors
curl https://api.zhong.nz/api/authors

# Register new user
curl -X POST https://api.zhong.nz/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!","email":"test@example.com"}'

# Login
curl -X POST https://api.zhong.nz/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!"}'

# Create book (requires JWT token from login)
curl -X POST https://api.zhong.nz/api/books \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{"title":"Test Book","isbn":"1234567890","publishedDate":"2024-01-01","authorId":1}'
```

**Frontend Tests:**
```
1. Open https://app.zhong.nz
2. Test user flows:
   - View books list
   - View book details
   - Register new account
   - Login
   - Create new book
   - Edit book
   - Delete book
   - Logout
3. Test error handling:
   - Try invalid login
   - Try creating book without auth
   - Try invalid ISBN format
4. Test performance:
   - Page load time < 3 seconds
   - API response time < 500ms
```

**Infrastructure Tests:**
```bash
# Verify ECS service is stable
aws ecs describe-services \
  --cluster tech-demo-production-cluster \
  --services tech-demo-production-service \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}' \
  --profile new-aws-account

# Verify RDS is available
aws rds describe-db-instances \
  --db-instance-identifier tech-demo-production-db \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Endpoint:Endpoint.Address}' \
  --profile new-aws-account

# Verify Lambda function works
aws lambda invoke \
  --function-name tech-demo-production-dns-updater \
  --payload '{}' \
  --profile new-aws-account \
  response.json

# Verify CloudFront distribution
aws cloudfront get-distribution \
  --id <DISTRIBUTION_ID> \
  --query 'Distribution.{Status:Status,DomainName:DomainName}' \
  --profile new-aws-account
```

**Expected Results:**
- ✅ All API endpoints respond correctly
- ✅ Frontend loads and functions properly
- ✅ User authentication works
- ✅ CRUD operations work
- ✅ Infrastructure is stable
- ✅ No errors in CloudWatch logs

### 7.2 Monitor for 24-48 Hours
**Action:**
```
1. Check CloudWatch metrics daily:
   - ECS CPU/Memory usage
   - RDS connections
   - CloudFront requests
   - Lambda invocations

2. Check CloudWatch logs for errors:
   - /ecs/tech-demo-production
   - /aws/lambda/tech-demo-production-dns-updater

3. Monitor costs:
   - AWS Console → Billing Dashboard
   - Should be $0 (free tier)

4. Test from different locations/devices:
   - Desktop browser
   - Mobile browser
   - Different networks
```

**Expected Result:**
- No errors in logs
- Costs remain at $0 (free tier)
- Application stable and responsive

### 7.3 Update Documentation
**Action:**
```bash
# Update README.md with any new information
# Update CV/portfolio if needed (repo URL is same, so probably no changes)
# Document any lessons learned
```

---

## 📊 COST BREAKDOWN

### Current Setup (Old Account - Free Tier Expired)
| Service | Monthly Cost |
|---------|-------------|
| RDS MySQL (db.t4g.micro) | $12-15 |
| ECS Fargate (256 CPU, 512 MB) | $5-8 |
| CloudFront | $1-3 |
| Route 53 | $1 |
| Lambda + CloudWatch | <$1 |
| **Total** | **$20-28/month** |

### New Setup (New Account - Free Tier Active)
| Service | Monthly Cost | Free Tier |
|---------|-------------|-----------|
| RDS MySQL (db.t4g.micro) | $0 | 750 hours/month |
| ECS Fargate (256 CPU, 512 MB) | $0 | 750 hours/month |
| CloudFront | $0 | 50GB data transfer |
| Route 53 | $1 | (not free) |
| Lambda + CloudWatch | $0 | 1M requests/month |
| **Total** | **$1/month** | **12 months** |

**Savings:** $240-336 over 12 months

---

## ⚠️ CRITICAL WARNINGS & RISKS

### Git History Rewrite Risks
1. **Cannot be undone** - Make backup first (Phase 2.1)
2. **Breaks existing clones** - Anyone who cloned repo must re-clone
3. **Loses all commit history** - Only current state preserved
4. **May break GitHub integrations** - Check after rewrite

### AWS Migration Risks
1. **Data loss** - Export database before destroying old account
2. **Downtime** - Expect 15-30 minutes during migration
3. **DNS propagation** - May take up to 48 hours (usually <1 hour)
4. **Cost surprises** - Monitor billing dashboard daily for first week

### Mitigation Strategies
1. ✅ **Backup everything** - Git repo, database, Terraform state
2. ✅ **Test in phases** - Don't destroy old account until new one works
3. ✅ **Monitor closely** - Check logs and metrics for 48 hours
4. ✅ **Keep old account** - Don't close for at least 1 week

---

## 🎯 SUCCESS CRITERIA

### Migration Complete When:
- ✅ New AWS account has all infrastructure running
- ✅ API responds at https://api.zhong.nz
- ✅ Frontend works at https://app.zhong.nz
- ✅ Git history has only 1 clean commit
- ✅ CI/CD pipeline works with new account
- ✅ No errors in CloudWatch logs for 24 hours
- ✅ Costs are $0-1/month (free tier)
- ✅ Old account infrastructure destroyed

### Quality Checks:
- ✅ All API endpoints tested and working
- ✅ Frontend fully functional
- ✅ User authentication works
- ✅ Database migrations run successfully
- ✅ No sensitive data in Git history
- ✅ Documentation updated
- ✅ Monitoring and alerts configured

---

## 📞 ROLLBACK PLAN

### If Migration Fails:

**Option 1: Restore Old AWS Account**
```bash
# If you haven't destroyed old account yet:
1. Update GitHub secrets back to old AWS role ARN
2. Update Terraform backend to old S3 bucket
3. Continue using old account
```

**Option 2: Restore Git History**
```bash
# Restore from backup
cd c:\Development\Projects
rm -rf TechDemo
cp -r TechDemo-backup-<date> TechDemo
cd TechDemo
git push -f origin main
```

**Option 3: Start Over**
```bash
# If both fail, you have:
1. Backup of Git repo
2. Database export (if you did Phase 2.2)
3. Terraform code (can recreate infrastructure)
```

---

## 📋 CHECKLIST

### Pre-Migration
- [ ] Read entire migration plan
- [ ] Understand risks and warnings
- [ ] Have 6-8 hours available over 2-3 days
- [ ] Backup current Git repository
- [ ] Export database (if needed)
- [ ] Create new AWS account
- [ ] Verify new AWS account email

### Phase 1: New AWS Account
- [ ] Create IAM user for local access
- [ ] Configure AWS CLI with new profile
- [ ] Update bootstrap terraform.tfvars
- [ ] Run terraform apply in bootstrap
- [ ] Save bootstrap outputs (S3 bucket, DynamoDB table, OIDC ARN)

### Phase 2: Clean Git History
- [ ] Backup repository to separate folder
- [ ] Create orphan branch
- [ ] Create single clean commit
- [ ] Delete old main branch
- [ ] Force push to GitHub
- [ ] Verify GitHub shows only 1 commit

### Phase 3: Update Configuration
- [ ] Update Terraform backend in main.tf
- [ ] Update terraform.tfvars with new S3 bucket
- [ ] Update GitHub secret: AWS_ROLE_TO_ASSUME
- [ ] Verify/update GitHub secret: DB_PASSWORD
- [ ] Plan domain DNS strategy
- [ ] Commit and push configuration changes

### Phase 4: Deploy to New AWS
- [ ] Run terraform init -reconfigure
- [ ] Run terraform plan (review carefully)
- [ ] Run terraform apply
- [ ] Save Terraform outputs
- [ ] Trigger CI/CD pipeline
- [ ] Monitor GitHub Actions workflow
- [ ] Test API health endpoint
- [ ] Verify ECS service running
- [ ] Verify CloudFront deployed

### Phase 5: Update Vercel
- [ ] Verify VITE_API_URL environment variable
- [ ] Test frontend at app.zhong.nz
- [ ] Verify API calls work
- [ ] Check browser console for errors
- [ ] Test user authentication flow

### Phase 6: Cleanup Old Account
- [ ] Verify new account works perfectly
- [ ] Export any remaining data from old account
- [ ] Run terraform destroy in old account
- [ ] Delete ECR images
- [ ] Delete CloudWatch logs (optional)
- [ ] Delete S3 state bucket (optional)
- [ ] Consider closing old account (wait 1 week)

### Phase 7: Verification
- [ ] Run all API endpoint tests
- [ ] Run all frontend tests
- [ ] Check CloudWatch metrics
- [ ] Check CloudWatch logs for errors
- [ ] Monitor costs (should be $0-1)
- [ ] Test from multiple devices/networks
- [ ] Monitor for 24-48 hours
- [ ] Update documentation

### Post-Migration
- [ ] Verify costs after 1 week
- [ ] Verify stability after 1 week
- [ ] Close old AWS account (if desired)
- [ ] Update CV/portfolio (if needed)
- [ ] Delete backup folder (after 1 month)

---

## 🆘 SUPPORT & RESOURCES

### AWS Documentation
- [AWS Free Tier](https://aws.amazon.com/free/)
- [ECS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
- [RDS Pricing](https://aws.amazon.com/rds/mysql/pricing/)
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)

### Terraform Documentation
- [S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [State Management](https://www.terraform.io/docs/language/state/index.html)

### Git Documentation
- [Rewriting History](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)
- [git-filter-repo](https://github.com/newren/git-filter-repo)

### Troubleshooting Commands
```bash
# Check AWS account
aws sts get-caller-identity

# Check Terraform state
terraform state list

# Check ECS tasks
aws ecs list-tasks --cluster tech-demo-production-cluster

# Check CloudWatch logs
aws logs tail /ecs/tech-demo-production --follow

# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID>
```

---

## 📝 NOTES & TIPS

### Time-Saving Tips
1. **Run Terraform locally first** - Faster than waiting for CI/CD
2. **Use AWS CLI profiles** - Easy to switch between old/new accounts
3. **Keep both accounts active** - Don't destroy old until new is verified
4. **Monitor costs daily** - Catch any unexpected charges early

### Common Mistakes to Avoid
1. ❌ Destroying old account before verifying new one works
2. ❌ Forgetting to update GitHub secrets
3. ❌ Not backing up database before migration
4. ❌ Force pushing Git without backup
5. ❌ Closing old AWS account too quickly

### Best Practices
1. ✅ Test each phase before moving to next
2. ✅ Keep detailed notes of what you did
3. ✅ Take screenshots of important configurations
4. ✅ Monitor CloudWatch logs closely
5. ✅ Wait 1 week before closing old account

---

## 🎉 CONCLUSION

This migration will:
- ✅ Save you $240-336 over 12 months
- ✅ Remove all sensitive data from Git history
- ✅ Give you a clean, professional portfolio project
- ✅ Maintain same GitHub repo URL (CV stays valid)
- ✅ Provide hands-on experience with AWS migration

**Estimated Total Time:** 6-8 hours over 2-3 days
**Difficulty Level:** Intermediate
**Risk Level:** Medium (with proper backups: Low)

**Good luck with your migration! 🚀**

---

**Document Version:** 1.0
**Last Updated:** 2024-11-21
**Author:** Migration Plan for tech-demo project

