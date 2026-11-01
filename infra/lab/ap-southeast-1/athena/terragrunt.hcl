include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/athena.hcl"
  expose = true
}

dependency "s3" {
  config_path = "../s3"

  # Used only when s3 has no outputs (plan before first apply, state list after destroy).
  mock_outputs = {
    s3_bucket_id = "fluss-lab-mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "state"]
}

inputs = {
  output_location = "s3://${dependency.s3.outputs.s3_bucket_id}/athena-results/"
}
