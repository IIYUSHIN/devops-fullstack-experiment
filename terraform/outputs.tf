# ============================================
# Terraform — Outputs
# ============================================
# After running "terraform apply", these values are displayed.
# Use these to access your deployed application.

# The URL to access your application
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — access your app here"
  value       = "http://${aws_lb.main.dns_name}"
}

# ECS Cluster name
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ECS Service name
output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Target Group ARN
output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}
