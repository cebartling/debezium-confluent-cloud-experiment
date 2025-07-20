#!/bin/bash
set -e

CONNECTOR_VERSION="3.2.0.Final"
PLUGIN_DIR="./plugins/debezium-postgres"

mkdir -p "${PLUGIN_DIR}"

echo "Downloading Debezium PostgreSQL connector version ${CONNECTOR_VERSION}..."
curl -L "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${CONNECTOR_VERSION}/debezium-connector-postgres-${CONNECTOR_VERSION}-plugin.tar.gz" \
  | tar -xz -C "${PLUGIN_DIR}"

echo "✅ Connector extracted to ${PLUGIN_DIR}"

