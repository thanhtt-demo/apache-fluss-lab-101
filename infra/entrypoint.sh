#!/bin/sh
# Optional TF_REGISTRY_MIRROR: redirect registry.terraform.io service discovery to a mirror.
# Provider addresses stay registry.terraform.io/hashicorp/aws, so .terraform.lock.hcl is unaffected.
set -eu
if [ -n "${TF_REGISTRY_MIRROR:-}" ]; then
  m="${TF_REGISTRY_MIRROR%/}"
  cat > "${HOME:-/tmp}/.terraformrc" <<EOF
host "registry.terraform.io" {
  services = {
    "modules.v1"   = "$m/v1/modules/",
    "providers.v1" = "$m/v1/providers/"
  }
}
EOF
fi
exec terragrunt "$@"
