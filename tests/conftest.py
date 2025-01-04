import pytest
from src.psql_service.psql_connection import PSQL_CONNECTION
from src.redis_service.redis_connection import REDIS_CONNECTION
from src.mongodb_service.mongodb_connection import MONGODB_CONNECTION
from src.cassandra_service.cassandra_connection import CASSANDRA_CONNECTION

# # PostgreSQL Fixture
@pytest.fixture(autouse=True)
def setup_psql():
    # No updates happen to PSQL DB
    yield

# MongoDB Fixture
@pytest.fixture(autouse=True)
def setup_mongo():
    connection = MONGODB_CONNECTION()
    mongodb = connection.client['polyglot']
    mongodb['statements'].delete_many({})

    yield

    mongodb['statements'].delete_many({})

# Cassandra Fixture
@pytest.fixture(autouse=True)
def setup_cassandra():
    connection = CASSANDRA_CONNECTION("polyglot_logs")
    cassandra = connection.cluster
    cassandra.execute("TRUNCATE polyglot_logs.logs")

    yield

    cassandra.execute("TRUNCATE polyglot_logs.logs")

# Redis Fixture
@pytest.fixture(autouse=True)
def setup_redis():
    connection = REDIS_CONNECTION()
    redis = connection.client    
    redis.flushdb()

    yield

    redis.flushdb()
    redis.close()
    
