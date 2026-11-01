# Fluss 1.0.0 with the jars required for an AWS Glue Iceberg catalog (per the Fluss "AWS Glue" docs).
# fluss-lake-iceberg and fluss-fs-s3 already ship with the distribution.
ARG FLUSS_IMAGE=docker.io/apache/fluss:1.0.0
FROM ${FLUSS_IMAGE}

ARG ICEBERG_VERSION=1.10.1
ARG FAILSAFE_VERSION=3.3.2
ARG MAVEN=https://repo1.maven.org/maven2

ADD ${MAVEN}/org/apache/iceberg/iceberg-aws/${ICEBERG_VERSION}/iceberg-aws-${ICEBERG_VERSION}.jar /opt/fluss/plugins/iceberg/
ADD ${MAVEN}/org/apache/iceberg/iceberg-aws-bundle/${ICEBERG_VERSION}/iceberg-aws-bundle-${ICEBERG_VERSION}.jar /opt/fluss/plugins/iceberg/
ADD ${MAVEN}/dev/failsafe/failsafe/${FAILSAFE_VERSION}/failsafe-${FAILSAFE_VERSION}.jar /opt/fluss/plugins/iceberg/

# SHA-1 from Maven Central; a mirror must serve identical bytes.
RUN set -eu; \
    cd /opt/fluss/plugins/iceberg; \
    printf '%s  %s\n' \
      55eefb7ca5f70f6ea6c31b0ec8e2df57ea258e01 "iceberg-aws-${ICEBERG_VERSION}.jar" \
      9c02c851a2356f287f040ed784170c758369d134 "iceberg-aws-bundle-${ICEBERG_VERSION}.jar" \
      738a986f1f0e4b6c6a49d351dddc772d1378c5a8 "failsafe-${FAILSAFE_VERSION}.jar" \
      | sha1sum -c -; \
    chmod 644 ./*.jar; \
    chown -R fluss:fluss /opt/fluss/plugins; \
    ls /opt/fluss/plugins/s3/ | grep -q fluss-fs-s3
