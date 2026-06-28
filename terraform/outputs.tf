output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = module.api_gateway.api_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb_table.dynamodb_table_id
}