# ============================================
# Terraform — Auto-Scaling
# ============================================
# Auto-scaling automatically adjusts the number of running ECS tasks
# based on CPU utilization.
#
# Configuration:
#   - Minimum: 2 tasks (always running)
#   - Maximum: 4 tasks (during high load)
#   - Scale UP when CPU > 70%
#   - Scale DOWN when CPU < 30%
#
# This ensures:
#   - High availability (always at least 2 tasks)
#   - Cost efficiency (don't run 4 tasks when traffic is low)
#   - Performance (add tasks when CPU is high)

# ── Auto-Scaling Target ──
# Registers the ECS service as a scalable target
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ── Scale Up Policy ──
# When average CPU goes ABOVE 70%, add 1 more task
# Cooldown: 60 seconds (wait before scaling again to avoid over-scaling)
resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.app_name}-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# ── Scale Down Policy ──
# When average CPU drops BELOW 30%, remove 1 task
# Cooldown: 120 seconds (longer cooldown to avoid premature scale-down)
resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.app_name}-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# ── CloudWatch Alarm: High CPU ──
# Triggers the scale-up policy when CPU > 70% for 2 consecutive minutes
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up when CPU > 70%"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

# ── CloudWatch Alarm: Low CPU ──
# Triggers the scale-down policy when CPU < 30% for 5 consecutive minutes
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.app_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down when CPU < 30%"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}
