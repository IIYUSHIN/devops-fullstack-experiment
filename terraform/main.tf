# ============================================
# PART 3: Terraform — Main Configuration
# ============================================
# This file defines the Terraform provider and general settings.
#
# WHAT IS TERRAFORM?
# Terraform is an Infrastructure as Code (IaC) tool.
# Instead of clicking through the AWS console to create resources,
# you write configuration files and run "terraform apply".
# Terraform then creates/updates/destroys AWS resources to match your config.

# ── Terraform Settings ──
terraform {
  # Minimum Terraform version required
  required_version = ">= 1.5.0"

  # Required providers (plugins that talk to cloud APIs)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── AWS Provider Configuration ──
# Tells Terraform to use AWS and which region to create resources in
provider "aws" {
  region = var.aws_region

  # Default tags applied to ALL resources created by Terraform
  default_tags {
    tags = {
      Project     = var.app_name
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}
