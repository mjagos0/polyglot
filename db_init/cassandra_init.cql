CREATE KEYSPACE IF NOT EXISTS polyglot_logs 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE polyglot_logs;

CREATE TABLE logs (
    userId INT,
    timestamp TIMESTAMP,
    action TEXT,
    parameters MAP<TEXT, TEXT>,
    tags LIST<TEXT>,
    PRIMARY KEY ((userId), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);