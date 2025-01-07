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

# Neo4j
echo "Initializing Neo4j Database..."
docker cp "$DB_INIT_PATH/neo4j_init.cypher" neo4j:/tmp/neo4j_init.cypher
docker exec neo4j cypher-shell -u neo4j -p password -f /tmp/neo4j_init.cypher
