# ============================================
# Terraform — ALB (Application Load Balancer)
# ============================================
# The ALB sits in front of our ECS tasks and distributes incoming traffic.
#
# How it works:
#   User → ALB (port 80) → Target Group → ECS Tasks (port 8080)
#
# Components:
#   ├── Security Group — allows HTTP traffic on port 80
#   ├── Application Load Balancer — the load balancer itself
#   ├── Target Group — a group of ECS tasks to send traffic to
#   └── Listener — listens on port 80 and forwards to target group

# ── Security Group for ALB ──
# Allows incoming HTTP traffic from anywhere on port 80
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow HTTP inbound traffic to ALB"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere (for future SSL setup)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (to reach ECS tasks)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

# ── Application Load Balancer ──
# Distributes traffic across ECS tasks in both subnets (both AZs)
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  # Enable deletion protection in production (set to false for experiment)
  enable_deletion_protection = false

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# ── Target Group ──
# A group of targets (ECS tasks) that the ALB sends traffic to
# The ALB health-checks each target to ensure it's healthy
resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  # Health check configuration
  # ALB periodically hits this endpoint to verify the container is healthy
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  # Allow time for old connections to drain during deployments
  deregistration_delay = 30

  tags = {
    Name = "${var.app_name}-target-group"
  }
}

# ── Listener ──
# Listens on port 80 and forwards all traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
