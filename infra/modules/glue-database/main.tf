# Provider version is pinned by root.hcl (versions_override.tf).
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  description = "Glue database name, [a-z0-9_] only"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]{1,252}$", var.name))
    error_message = "Glue/Iceberg only accept lowercase names matching [a-z0-9_]."
  }
}

variable "description" {
  description = "Database description"
  type        = string
  default     = null
}

resource "aws_glue_catalog_database" "this" {
  name        = var.name
  description = var.description
}

output "name" {
  value = aws_glue_catalog_database.this.name
}

output "arn" {
  value = aws_glue_catalog_database.this.arn
}
