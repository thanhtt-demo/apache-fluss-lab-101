# Terraform + Terragrunt in one image so the host only needs Docker.
ARG TERRAFORM_IMAGE=docker.io/hashicorp/terraform:1.14.9
FROM ${TERRAFORM_IMAGE}

ARG TERRAGRUNT_VERSION=0.97.2
ARG GITHUB_MIRROR=https://github.com
# From the v0.97.2 release SHA256SUMS.
ARG TERRAGRUNT_SHA256_AMD64=283aba29a6dfb92544d4b1e8dbb210aa3a01db2575f683d7c41a0e0b53a72727
ARG TERRAGRUNT_SHA256_ARM64=c29185aa5931340695bd855d20e278888b2c33fc3979fb1e1c79e9008df899ad
ARG TARGETARCH

RUN set -eu; \
    arch="${TARGETARCH:-amd64}"; \
    case "$arch" in \
      amd64) sum="$TERRAGRUNT_SHA256_AMD64" ;; \
      arm64) sum="$TERRAGRUNT_SHA256_ARM64" ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    wget -q -O /usr/local/bin/terragrunt \
      "${GITHUB_MIRROR%/}/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${arch}"; \
    echo "${sum}  /usr/local/bin/terragrunt" | sha256sum -c -; \
    chmod 755 /usr/local/bin/terragrunt; \
    terragrunt --version; \
    terraform version

# Skip checkpoint-api.hashicorp.com; on restricted networks `terraform version` hangs on it.
ENV CHECKPOINT_DISABLE=1
COPY entrypoint.sh /usr/local/bin/infra-entrypoint.sh
RUN chmod 755 /usr/local/bin/infra-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/infra-entrypoint.sh"]
