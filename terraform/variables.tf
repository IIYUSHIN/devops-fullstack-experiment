# ============================================
# Terraform — Input Variables
# ============================================
# Variables let you customize the deployment without editing code.
# Values are set in terraform.tfvars

# AWS region where all resources will be created
variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

# Application name — used for naming resources
variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "devops-experiment"
}

# The Docker image URL to deploy
# This should be the GHCR image from our CI/CD pipeline
variable "container_image" {
  description = "Docker image URL to deploy (from GHCR)"
  type        = string
  default     = "ghcr.io/your-username/devops-fullstack-experiment:latest"
}

# Port the container listens on (must match Nginx config)
variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 8080
}

# CPU units for each container (256 = 0.25 vCPU)
variable "task_cpu" {
  description = "CPU units for ECS task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

# Memory in MB for each container
variable "task_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 512
}

# Number of containers to run normally
variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

# Auto-scaling limits
variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}
