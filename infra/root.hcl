locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  master_prefix = local.common_vars.locals.master_prefix
  env           = local.env_vars.locals.env
  aws_region    = local.region_vars.locals.aws_region

  prefix = "${local.master_prefix}-${local.env}"

  # Must start with "fluss-tfstate-" to match iam-policy.json.
  state_bucket = get_env("TF_STATE_BUCKET")
}

# Covers the pinned container versions and a compatible host install.
terraform_version_constraint  = ">= 1.14.3, < 1.16.0"
terragrunt_version_constraint = ">= 0.97.0, < 1.1.0"

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = local.state_bucket
    # Normalize Windows path separators so host and container runs share the same state key.
    key                  = "${replace(path_relative_to_include(), "\\", "/")}/terraform.tfstate"
    region               = local.aws_region
    encrypt              = true
    use_lockfile         = true     # S3-native locking, no DynamoDB
    bucket_sse_algorithm = "AES256" # Terragrunt defaults to aws:kms
    s3_bucket_tags = {
      project = "fluss-lab"
      purpose = "terraform-state"
    }
  }
}

# An *_override.tf merges with the registry module's own required_providers instead of conflicting.
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.14.3, < 1.16.0"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "6.69.1"
        }
      }
    }
  EOF
}

# Credentials come from AWS_* environment variables; no profile.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
      default_tags {
        tags = {
          project    = "fluss-lab"
          managed-by = "terragrunt"
        }
      }
    }
  EOF
}

inputs = {
  prefix     = local.prefix
  aws_region = local.aws_region
}
