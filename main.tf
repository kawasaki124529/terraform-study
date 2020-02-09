module "dev_server" {
  source        = "./http_server"
  instance_type = "t3.micro"
}

module "describe_regions_for_ec2" {
  source     = "./iam_role"
  name       = "describe-regionsfor-ec2"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.allow_describe.json
}

output "public_dns" {
  value = module.dev_server.public_dns
}

# S3設定
resource "aws_s3_bucket" "private" {
  # バケット名（世界で一意）
  bucket = "private-kawasaki-terraform-on-aws"
  # 　バージョニング
  versioning {
    enabled = true
  }
  # 暗号化
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
# S3公開ルール（以下はプライベートバケット
resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# ログバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-kawasaki-terraform-on-aws"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}
# バケットポリシー
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json

  data "aws_iam_policy_document" "alb_log" {
    statement {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["arn:aws:s3:::${aws_s3_buckt.alb_log.id}/*"]

      principals {
        type       = "AWS"
        identifier = [101696717337]
      }
    }
  }
}
