resource "aws_dynamodb_table" "terraform_locks" {
  #checkov:skip=CKV_AWS_119: "Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  #The dynamodb table created is encrypted via AWS key using server_side_encryption
  name         = "${var.environment}-ld-stor-dyt-terraformstate"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  #checkov:skip=CKV_AWS_28:This is a cache table
  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
