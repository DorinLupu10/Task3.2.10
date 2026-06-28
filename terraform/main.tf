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