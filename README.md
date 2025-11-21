# Bookstore - Full-Stack Cloud Application

**Tech Stack**: .NET 9 API • React TypeScript • AWS ECS Fargate • Terraform • GitHub Actions CI/CD

## 🚀 Live Demo

- **Frontend**: [app.zhong.nz](https://app.zhong.nz) - React SPA on Vercel
- **API**: [api.zhong.nz](http://api.zhong.nz) - .NET 9 on AWS ECS Fargate  

> **Note**: This is a portfolio demonstration project. The infrastructure is live and functional, but not intended for production use.

## ✨ Key Features

- 🔐 **JWT Authentication** - Secure login with token-based auth
- 📚 **Book Management** - Browse books and authors with detailed views
- 🚀 **Zero-Downtime Deploys** - Automated CI/CD with ECS rolling updates
- 📊 **Auto-Scaling** - ECS Fargate handles traffic spikes automatically
- 📡 **Dynamic DNS** - Lambda automatically updates Route53 when task IP changes
- 🏗️ **Infrastructure as Code** - Complete AWS infrastructure provisioned with Terraform
- 🔒 **Secure by Default** - BCrypt password hashing, CORS configured, HTTPS enforced

## 🏗️ Architecture Overview

```
╭─────────────────────────────────────────╮
│ Frontend (app.zhong.nz)                 │
│ • Vercel                                │
│ • React + TypeScript + Vite             │
│ • Auto-deploy from Git                  │
╰─────────────────────────────────────────╯
              ↓ HTTPS API calls
╭─────────────────────────────────────────╮
│ Backend (api.zhong.nz)                  │
│ • AWS ECS Fargate                       │
│ • .NET 9 Web API + JWT Auth             │
│ • Public IP (no ALB needed)             │
╰─────────────────────────────────────────╯
       ↓                   ↓
╭───────────╮    ╭────────────────────╮
│ Database  │    │ Lambda + Route53   │
│ RDS MySQL │    │ Auto-update DNS    │
╰───────────╯    ╰────────────────────╯
```

**Key Architecture Decisions**:
- ✅ **No ALB** - Fargate public IP + Lambda DNS updates
- ✅ **Spot instances** - 70% cost savings on compute
- ✅ **Vercel for frontend** - Free CDN and hosting
- ✅ **JWT auth** - Stateless authentication
- ✅ **Automated migrations** - Database schema updates on deploy

### Backend (AWS)

**Infrastructure**:
- **ECS Fargate Spot** - Serverless container runtime
- **RDS MySQL t4g.micro** - Managed database  
- **Lambda** - Automatic DNS updates on task IP changes
- **EventBridge** - Triggers Lambda on ECS task state changes
- **Route53** - DNS management for api.zhong.nz

**Deployment Flow**:
```
Git Push → GitHub Actions → Docker Build → ECR → ECS Fargate
                ↓
        Database Migration
```

## 🛠️ Technology Stack

### Backend
- **.NET 9** - Latest C# web framework
- **Entity Framework Core** - ORM with code-first migrations
- **MySQL** - Relational database
- **JWT Authentication** - Secure token-based auth
- **BCrypt** - Password hashing
- **Swagger/OpenAPI** - API documentation

### Frontend  
- **React 18** - Modern UI library
- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool and dev server
- **React Router** - Client-side routing

### Infrastructure
- **AWS ECS Fargate** - Serverless containers
- **AWS Lambda** - Serverless functions
- **AWS RDS** - Managed MySQL database
- **Terraform** - Infrastructure as Code
- **Docker** - Containerization
- **GitHub Actions** - CI/CD pipeline
- **Vercel** - Frontend hosting

## 🤖 AI-Assisted Development

This project was built with the assistance of modern AI coding tools:

- **Codex**
- **Qoder**
- **Augment Code**

## 🔒 Security

This repository follows security best practices:

- ✅ **No secrets in source code** - All credentials via environment variables
- ✅ **GitHub Actions secrets** - Sensitive data in GitHub Secrets
- ✅ **Terraform state** - Stored remotely in S3, not committed
- ✅ **Password hashing** - BCrypt with cost factor 11
- ✅ **JWT authentication** - Cryptographically secure tokens