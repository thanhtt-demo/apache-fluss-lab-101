# Provider version is pinned by root.hcl (versions_override.tf).
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  description = "Workgroup name"
  type        = string
}

variable "output_location" {
  description = "s3://bucket/prefix/ for query results"
  type        = string
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Per-query scan limit in bytes (provider minimum 10485760)"
  type        = number
  default     = 104857600
}

resource "aws_athena_workgroup" "this" {
  name = var.name
  # Allows destroy while saved queries or query history exist.
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    engine_version {
      selected_engine_version = "Athena engine version 3"
    }

    result_configuration {
      output_location = var.output_location

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

output "name" {
  value = aws_athena_workgroup.this.name
}
