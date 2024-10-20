#######################################
#S3 Bucket for Terraform States Primary
#######################################

resource "aws_s3_bucket" "state_bucket_primary" {
  bucket = "bwt-terraform-states"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

##########################################
#Dynamodb tables for Terraform State Locks
##########################################

resource "aws_dynamodb_table" "terraform_state_lock_primary" {
  name           = "terraform-state-lock"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
