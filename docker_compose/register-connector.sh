#!/bin/bash

echo "Waiting for Kafka Connect to be ready..."
until curl -s http://localhost:8083/ | grep -q "kafka_cluster_id"; do
  echo "Kafka Connect is not ready yet. Retrying in 2 seconds..."
  sleep 2
done

echo "Registering Debezium PostgreSQL connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "postgres-customers-connector",
    "config": {
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
      "transforms.unwrap.delete.handling.mode": "rewrite"
    }
  }'