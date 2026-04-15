# ============================================
# Terraform Variable Values
# ============================================
# Edit these values to customize your deployment.
# This file is loaded automatically by Terraform.

aws_region      = "us-east-1"
app_name        = "devops-experiment"
container_image = "ghcr.io/your-username/devops-fullstack-experiment:latest"
container_port  = 8080
task_cpu        = 256
task_memory     = 512
desired_count   = 2
min_capacity    = 2
max_capacity    = 4
