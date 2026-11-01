# Debezium Connect plus the Confluent Avro converter, which Debezium images no longer bundle since 2.0
# (https://debezium.io/documentation/reference/3.7/configuration/avro.html).
# Jars are fetched from Maven and SHA-1 verified against avro-converter-jars.txt. Most io.confluent
# artifacts exist only on packages.confluent.io, hence the fallback repo.
ARG TERRAFORM_IMAGE=docker.io/hashicorp/terraform:1.14.9
ARG CONNECT_BASE_IMAGE=quay.io/debezium/connect:3.7.0.Final

# Reuses the already-pinned Terraform image (Alpine with wget + sha1sum) as a fetch stage.
FROM ${TERRAFORM_IMAGE} AS fetch
ARG MAVEN_REPO=https://repo1.maven.org/maven2
ARG CONFLUENT_MAVEN_REPO=https://packages.confluent.io/maven
COPY avro-converter-jars.txt /tmp/jars.txt
RUN set -eu; \
    mkdir -p /tmp/avro-lib; cd /tmp/avro-lib; \
    grep -v '^#' /tmp/jars.txt | while read -r sum gav; do \
      [ -n "$sum" ] || continue; \
      g="${gav%%:*}"; rest="${gav#*:}"; a="${rest%%:*}"; v="${rest#*:}"; f="$a-$v.jar"; \
      ok=""; \
      for repo in "$MAVEN_REPO" "$CONFLUENT_MAVEN_REPO"; do \
        if wget -q -O "$f" "${repo%/}/$g/$a/$v/$f" && echo "$sum  $f" | sha1sum -c -s -; then ok=1; break; fi; \
        rm -f "$f"; \
      done; \
      [ -n "$ok" ] || { echo "download failed or checksum mismatch: $f" >&2; exit 1; }; \
    done; \
    test "$(ls | wc -l)" -eq 38; \
    chmod 644 ./*.jar

FROM ${CONNECT_BASE_IMAGE}
# Each subdirectory of /kafka/connect is loaded with its own plugin classloader.
COPY --from=fetch /tmp/avro-lib/ /kafka/connect/confluent-avro-converter/
