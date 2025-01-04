#!/bin/bash

DB_INIT_PATH="$(pwd)/db_init"

# PostgreSQL Initialization
echo "Initializing PostgreSQL Database..."
docker cp "$DB_INIT_PATH/psql_init.sql" postgres:/tmp/psql_init.sql
docker exec -it postgres psql -U admin -d mydb -f /tmp/psql_init.sql

# MongoDB Initialization
echo "Initializing MongoDB Database..."
docker cp "$DB_INIT_PATH/mongodb_init.js" mongodb:/tmp/mongodb_init.js
docker exec -it mongodb mongosh /tmp/mongodb_init.js

# Cassandra Initialization
echo "Initializing Cassandra Database..."
docker cp "$DB_INIT_PATH/cassandra_init.cql" cassandra:/tmp/cassandra_init.cql
docker exec -it cassandra cqlsh -f /tmp/cassandra_init.cql