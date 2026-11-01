# Tables are created by Fluss when a table has table.datalake.enabled.
locals {
  base_source_url = "${dirname(find_in_parent_folders("root.hcl"))}/modules/glue-database"
}

terraform {
  source = local.base_source_url
}

inputs = {
  name        = "fluss_lab"
  description = "Fluss lab: Iceberg tables tiered by Fluss 1.0.0"
}
