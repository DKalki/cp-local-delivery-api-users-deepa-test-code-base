resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_18:This is a state bucket. It doesn't need access logging enabled.
  #checkov:skip=CKV_AWS_52:This is a state bucket. MFA delete is disabled.
  #checkov:skip=CKV_AWS_144:This is a state bucket. Cross region replication is not required.
  #checkov:skip=CKV2_AWS_62:"Ensure S3 buckets should have event notifications enabled"
  #checkov:skip=CKV2_AWS_61:"Ensure that an S3 bucket has a lifecycle configuration"
  bucket = "${var.environment}-ld-stor-s3-terraformstate"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}