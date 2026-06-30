# SNS Topic pentru alarme
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Lambda Widget
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Invocations & Errors"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-createNote"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-deleteNote"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-getNote"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-listNotes"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-updateNote"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-createNote"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-deleteNote"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-getNote"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-listNotes"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-updateNote"]
          ]
          view = "timeSeries"
        }
      },
      # Lambda Duration & Throttles
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Duration & Throttles"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-createNote"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-deleteNote"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-getNote"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-listNotes"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-updateNote"],
            ["AWS/Lambda", "Throttles", "FunctionName", "${var.project_name}-createNote"],
            ["AWS/Lambda", "Throttles", "FunctionName", "${var.project_name}-listNotes"]
          ]
          view = "timeSeries"
        }
      },
      # Lambda ConcurrentExecutions
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Concurrent Executions"
          period = 300
          stat   = "Maximum"
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.project_name}-createNote"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.project_name}-deleteNote"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.project_name}-getNote"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.project_name}-listNotes"],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${var.project_name}-updateNote"]
          ]
          view = "timeSeries"
        }
      },
      # API Gateway Widget
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway - Requests & Errors"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway.api_id],
            ["AWS/ApiGateway", "5xx", "ApiId", module.api_gateway.api_id],
            ["AWS/ApiGateway", "4xx", "ApiId", module.api_gateway.api_id],
            ["AWS/ApiGateway", "DataProcessed", "ApiId", module.api_gateway.api_id]
          ]
          view = "timeSeries"
        }
      },
      # API Gateway Latency
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway - Latency"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", module.api_gateway.api_id],
            ["AWS/ApiGateway", "IntegrationLatency", "ApiId", module.api_gateway.api_id]
          ]
          view = "timeSeries"
        }
      },
      # DynamoDB Widget
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB - Capacity & Latency"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", module.dynamodb_table.dynamodb_table_id],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", module.dynamodb_table.dynamodb_table_id],
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", module.dynamodb_table.dynamodb_table_id, "Operation", "PutItem"],
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", module.dynamodb_table.dynamodb_table_id, "Operation", "GetItem"]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

# CloudWatch Alarms - Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = toset(["createNote", "deleteNote", "getNote", "listNotes", "updateNote"])

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-errors"
  alarm_description   = "Lambda ${each.key} error rate too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${var.project_name}-${each.key}"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - Lambda Duration
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = toset(["createNote", "deleteNote", "getNote", "listNotes", "updateNote"])

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-duration"
  alarm_description   = "Lambda ${each.key} duration too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 5000
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${var.project_name}-${each.key}"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - Lambda Throttles
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = toset(["createNote", "deleteNote", "getNote", "listNotes", "updateNote"])

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-throttles"
  alarm_description   = "Lambda ${each.key} is being throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "${var.project_name}-${each.key}"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - API Gateway 5xx
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-api-5xx"
  alarm_description   = "API Gateway 5xx errors too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xx"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiId = module.api_gateway.api_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - API Gateway Latency
resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name          = "${var.project_name}-${var.environment}-api-latency"
  alarm_description   = "API Gateway latency too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Average"
  threshold           = 3000
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiId = module.api_gateway.api_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - DynamoDB Read Throttle
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-read-throttle"
  alarm_description   = "DynamoDB read throttling detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = module.dynamodb_table.dynamodb_table_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - DynamoDB Write Throttle
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-write-throttle"
  alarm_description   = "DynamoDB write throttling detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = module.dynamodb_table.dynamodb_table_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}