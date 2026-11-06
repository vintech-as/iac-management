# Organization trail: management events from every account and region, written
# to a bucket in the management account. The first copy of management events
# is free; only S3 storage is billed.
locals {
  org_trail_name   = "org-trail"
  org_trail_arn    = "arn:aws:cloudtrail:eu-west-1:${aws_organizations_organization.org.master_account_id}:trail/${local.org_trail_name}"
  org_trail_bucket = "vintech-org-cloudtrail-${aws_organizations_organization.org.master_account_id}"
}

resource "aws_s3_bucket" "org_trail" {
  bucket = local.org_trail_bucket

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "org_trail" {
  bucket                  = aws_s3_bucket.org_trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "org_trail" {
  bucket = aws_s3_bucket.org_trail.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "org_trail" {
  bucket = aws_s3_bucket.org_trail.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "org_trail" {
  bucket = aws_s3_bucket.org_trail.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = var.cloudtrail_retention_days
    }
  }
}

data "aws_iam_policy_document" "org_trail_bucket" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.org_trail.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.org_trail_arn]
    }
  }

  statement {
    sid     = "AWSCloudTrailWrite"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.org_trail.arn}/AWSLogs/${aws_organizations_organization.org.master_account_id}/*",
      "${aws_s3_bucket.org_trail.arn}/AWSLogs/${aws_organizations_organization.org.id}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.org_trail_arn]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.org_trail.arn, "${aws_s3_bucket.org_trail.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "org_trail" {
  bucket = aws_s3_bucket.org_trail.id
  policy = data.aws_iam_policy_document.org_trail_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.org_trail]
}

resource "aws_cloudtrail" "org" {
  name                          = local.org_trail_name
  s3_bucket_name                = aws_s3_bucket.org_trail.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  depends_on = [
    aws_s3_bucket_policy.org_trail,
    aws_organizations_organization.org,
  ]
}
