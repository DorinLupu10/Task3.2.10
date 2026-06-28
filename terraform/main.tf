module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"

  name         = "${var.project_name}-table"
  hash_key     = "noteId"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "noteId"
      type = "S"
    }
  ]

  tags = {
    Project = var.project_name
  }
}

# Lambda
module "lambda_create_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-createNote"
  handler       = "app.handler"
  runtime       = "nodejs22.x"

  source_path = "../packages/backend/dist/createNote/app.js"

  environment_variables = {
    NOTES_TABLE_NAME  = module.dynamodb_table.dynamodb_table_id
    AWS_ENDPOINT_URL  = "https://dynamodb.us-east-1.amazonaws.com"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:*"]
      resources = [module.dynamodb_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
    apigateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:us-east-1:449024774937:${module.api_gateway.api_id}/*"
    }
  }
  create_current_version_allowed_triggers = false

  tags = {
    Project = var.project_name
  }
}

module "lambda_delete_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-deleteNote"
  handler       = "app.handler"
  runtime       = "nodejs22.x"

  source_path = "../packages/backend/dist/deleteNote/app.js"

  environment_variables = {
    NOTES_TABLE_NAME  = module.dynamodb_table.dynamodb_table_id
    AWS_ENDPOINT_URL  = "https://dynamodb.us-east-1.amazonaws.com"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:*"]
      resources = [module.dynamodb_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
  apigateway = {
    service    = "apigateway"
    source_arn = "arn:aws:execute-api:us-east-1:449024774937:${module.api_gateway.api_id}/*"
  }
}

create_current_version_allowed_triggers = false

  tags = {
    Project = var.project_name
  }
}

module "lambda_get_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-getNote"
  handler       = "app.handler"
  runtime       = "nodejs22.x"

  source_path = "../packages/backend/dist/getNote/app.js"

  environment_variables = {
    NOTES_TABLE_NAME  = module.dynamodb_table.dynamodb_table_id
    AWS_ENDPOINT_URL  = "https://dynamodb.us-east-1.amazonaws.com"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:*"]
      resources = [module.dynamodb_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
  apigateway = {
    service    = "apigateway"
    source_arn = "arn:aws:execute-api:us-east-1:449024774937:${module.api_gateway.api_id}/*"
  }
}

create_current_version_allowed_triggers = false

  tags = {
    Project = var.project_name
  }
}

module "lambda_list_notes" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-listNotes"
  handler       = "app.handler"
  runtime       = "nodejs22.x"

  source_path = "../packages/backend/dist/listNotes/app.js"

  environment_variables = {
    NOTES_TABLE_NAME  = module.dynamodb_table.dynamodb_table_id
    AWS_ENDPOINT_URL  = "https://dynamodb.us-east-1.amazonaws.com"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:*"]
      resources = [module.dynamodb_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
  apigateway = {
    service    = "apigateway"
    source_arn = "arn:aws:execute-api:us-east-1:449024774937:${module.api_gateway.api_id}/*"
  }
}

create_current_version_allowed_triggers = false

  tags = {
    Project = var.project_name
  }
}

module "lambda_update_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-updateNote"
  handler       = "app.handler"
  runtime       = "nodejs22.x"

  source_path = "../packages/backend/dist/updateNote/app.js"

  environment_variables = {
    NOTES_TABLE_NAME  = module.dynamodb_table.dynamodb_table_id
    AWS_ENDPOINT_URL  = "https://dynamodb.us-east-1.amazonaws.com"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:*"]
      resources = [module.dynamodb_table.dynamodb_table_arn]
    }
  }

  allowed_triggers = {
  apigateway = {
    service    = "apigateway"
    source_arn = "arn:aws:execute-api:us-east-1:449024774937:${module.api_gateway.api_id}/*"
  }
}

create_current_version_allowed_triggers = false

  tags = {
    Project = var.project_name
  }
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 5.0"

  name          = "${var.project_name}-api"
  description   = "Notes API Gateway"
  protocol_type = "HTTP"
  create_domain_name = false

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
  }

  routes = {
    "POST /notes" = {
      integration = {
        uri                    = module.lambda_create_note.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
    "GET /notes" = {
      integration = {
        uri                    = module.lambda_list_notes.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
    "GET /notes/{id}" = {
      integration = {
        uri                    = module.lambda_get_note.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
    "PUT /notes/{id}" = {
      integration = {
        uri                    = module.lambda_update_note.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
    "DELETE /notes/{id}" = {
      integration = {
        uri                    = module.lambda_delete_note.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
  }

  tags = {
    Project = var.project_name
  }
}