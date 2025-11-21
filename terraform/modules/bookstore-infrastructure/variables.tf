variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "api_subdomain" {
  description = "API subdomain"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
}

variable "ecs_cpu" {
  description = "ECS task CPU units"
  type        = string
}

variable "ecs_memory" {
  description = "ECS task memory in MB"
  type        = string
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
}

variable "use_spot" {
  description = "Use Fargate Spot for cost savings"
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Docker container image"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
