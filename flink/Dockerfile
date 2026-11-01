# Fluss quickstart Flink 1.20 image plus the Kafka connector, Confluent Avro format and failsafe
# (needed by iceberg-aws for GlueCatalog). init_iceberg.sh copies /opt/flink/iceberg/ into lib/ at startup.
ARG FLINK_BASE_IMAGE=docker.io/apache/fluss-quickstart-flink:1.20-1.0.0
FROM ${FLINK_BASE_IMAGE}

ARG FLINK_KAFKA_CONNECTOR_VERSION=3.4.0-1.20
ARG FLINK_AVRO_CONFLUENT_VERSION=1.20.0
ARG FAILSAFE_VERSION=3.3.2
ARG MAVEN=https://repo1.maven.org/maven2

ADD ${MAVEN}/org/apache/flink/flink-sql-connector-kafka/${FLINK_KAFKA_CONNECTOR_VERSION}/flink-sql-connector-kafka-${FLINK_KAFKA_CONNECTOR_VERSION}.jar /opt/flink/lib/
ADD ${MAVEN}/org/apache/flink/flink-sql-avro-confluent-registry/${FLINK_AVRO_CONFLUENT_VERSION}/flink-sql-avro-confluent-registry-${FLINK_AVRO_CONFLUENT_VERSION}.jar /opt/flink/lib/
ADD ${MAVEN}/dev/failsafe/failsafe/${FAILSAFE_VERSION}/failsafe-${FAILSAFE_VERSION}.jar /opt/flink/lib/

# SHA-1 from Maven Central. ADD from a URL creates files with mode 600, hence the chmod.
RUN set -eu; \
    cd /opt/flink/lib; \
    printf '%s  %s\n' \
      266330f8f26fec4957339b5ff31aa67b81c31462 "flink-sql-connector-kafka-${FLINK_KAFKA_CONNECTOR_VERSION}.jar" \
      c3813cff31fa72c80c92270e85196f54a3380c76 "flink-sql-avro-confluent-registry-${FLINK_AVRO_CONFLUENT_VERSION}.jar" \
      738a986f1f0e4b6c6a49d351dddc772d1378c5a8 "failsafe-${FAILSAFE_VERSION}.jar" \
      | sha1sum -c -; \
    chmod 644 ./*.jar; \
    ls /opt/flink/iceberg/ > /opt/flink/lab-iceberg-jars.txt
