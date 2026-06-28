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

  tags = {
    Project = var.project_name
  }
}

module "lambda_delete_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-deleteNote"
  handler       = "app.handler"
  runtime       = "nodejs24.x"

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

  tags = {
    Project = var.project_name
  }
}

module "lambda_get_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-getNote"
  handler       = "app.handler"
  runtime       = "nodejs24.x"

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

  tags = {
    Project = var.project_name
  }
}

module "lambda_list_notes" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-listNotes"
  handler       = "app.handler"
  runtime       = "nodejs24.x"

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

  tags = {
    Project = var.project_name
  }
}

module "lambda_update_note" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.project_name}-updateNote"
  handler       = "app.handler"
  runtime       = "nodejs24.x"

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

  tags = {
    Project = var.project_name
  }
}