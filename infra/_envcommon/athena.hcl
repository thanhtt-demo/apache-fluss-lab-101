locals {
  base_source_url = "${dirname(find_in_parent_folders("root.hcl"))}/modules/athena-workgroup"
}

terraform {
  source = local.base_source_url
}

inputs = {
  name = "fluss-lab"
  # 100 MiB per query as a cost guardrail.
  bytes_scanned_cutoff_per_query = 104857600
}
