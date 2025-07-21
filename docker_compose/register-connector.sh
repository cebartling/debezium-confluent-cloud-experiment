#!/bin/bash

set -a
source .env
set +a


echo "Waiting for Kafka Connect to be ready..."
until curl -s http://localhost:8083/ | grep -q "kafka_cluster_id"; do
  echo "Kafka Connect is not ready yet. Retrying in 2 seconds..."
  sleep 2
done

echo "Registering Debezium PostgreSQL connector..."

CONFIG='{
  "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
  "database.hostname": "postgres",
  "database.port": "5432",
  "database.user": "postgres",
  "database.password": "postgres",
  "database.dbname": "inventory",
  "database.server.name": "pg1",
  "plugin.name": "pgoutput",
  "slot.name": "debezium_slot",
  "publication.autocreate.mode": "filtered",
  "table.include.list": "public.customers",
  "topic.creation.enable": "true",
  "topic.creation.default.replication.factor": 3,
  "topic.creation.default.partitions": 3,
  "topic.creation.default.cleanup.policy": "compact",
  "topic.prefix": "foobar",
  "transforms": "unwrap",
  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
  "transforms.unwrap.drop.tombstones": "true",
  "transforms.unwrap.delete.handling.mode": "rewrite",
  "bootstrap.servers": "'"$CLOUD_BOOTSTRAP_SERVERS"'",
  "security.protocol": "SASL_SSL",
  "sasl.mechanism": "PLAIN",
  "sasl.username": "'"$CLOUD_API_KEY"'",
  "sasl.password": "'"$CLOUD_API_SECRET"'",
  "consumer.security.protocol": "SASL_SSL",
  "consumer.sasl.mechanism": "PLAIN",
  "consumer.sasl.username": "'"$CLOUD_API_KEY"'",
  "consumer.sasl.password": "'"$CLOUD_API_SECRET"'",
  "producer.security.protocol": "SASL_SSL",
  "producer.sasl.mechanism": "PLAIN",
  "producer.sasl.username": "'"$CLOUD_API_KEY"'",
  "producer.sasl.password": "'"$CLOUD_API_SECRET"'",
  "schema.history.internal.kafka.bootstrap.servers": "'"$CLOUD_BOOTSTRAP_SERVERS"'",
  "schema.history.internal.kafka.security.protocol": "SASL_SSL",
  "schema.history.internal.kafka.sasl.mechanism": "PLAIN",
  "schema.history.internal.kafka.sasl.username": "'"$CLOUD_API_KEY"'",
  "schema.history.internal.kafka.sasl.password": "'"$CLOUD_API_SECRET"'"
}'

#RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT http://localhost:8083/connector-plugins/io.debezium.connector.postgresql.PostgresConnector/config/validate \
#  -H "Content-Type: application/json" \
#  -d "$CONFIG")
#
#echo "$RESPONSE"
#
#BODY=$(echo "$RESPONSE" | sed '$d')
#STATUS=$(echo "$RESPONSE" | tail -n1)
#
#echo "HTTP Status: $STATUS"
#
#echo "$BODY" | jq '.configs[] | select(.errors | length > 0)'

#
#if [ "$STATUS" -ne 200 ]; then
#  echo "$BODY" | jq '.configs[] | select(.errors | length > 0)'
#else
#  echo "Validation successful (HTTP $STATUS)."
#fi

DATA='{
         "name": "postgres-customers-connector",
         "config": '"$CONFIG"'
       }'

curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d "$DATA"