# Lab bucket: fluss-remote/, iceberg-warehouse/, athena-results/.
locals {
  module_version = "5.17.0"
  # GITHUB_MIRROR swaps the registry source for the same tagged release tarball.
  github_mirror = trimsuffix(get_env("GITHUB_MIRROR", ""), "/")
  base_source_url = (
    local.github_mirror == ""
    ? "tfr:///terraform-aws-modules/s3-bucket/aws//?version=${local.module_version}"
    : "${local.github_mirror}/terraform-aws-modules/terraform-aws-s3-bucket/archive/refs/tags/v${local.module_version}.tar.gz//terraform-aws-s3-bucket-${local.module_version}"
  )
}

terraform {
  source = local.base_source_url
}

inputs = {
  # Shared with Fluss/Flink via .env.infra; must start with "fluss-lab-" (iam-policy.json).
  bucket = get_env("LAB_BUCKET")

  # Must be set from the first apply, otherwise destroy fails on a non-empty bucket.
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  attach_deny_insecure_transport_policy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # No expiration on iceberg-warehouse/: deleting files there corrupts the tables.
  lifecycle_rule = [
    {
      id                                     = "abort-multipart"
      enabled                                = true
      filter                                 = {}
      abort_incomplete_multipart_upload_days = 1
    },
    {
      id         = "expire-athena-results"
      enabled    = true
      filter     = { prefix = "athena-results/" }
      expiration = { days = 7 }
    },
  ]
}
