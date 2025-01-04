from cassandra.cluster import Cluster

class CASSANDRA_CONNECTION:
    CASSANDRA_HOST = '127.0.0.1'
    CASSANDRA_PORT = 9042

    def __init__(self, keyspace: str):
        self.cluster = self.connect(keyspace)

    def connect(self, keyspace: str):
        cluster = Cluster([self.CASSANDRA_HOST], port=self.CASSANDRA_PORT)
        return cluster.connect(keyspace)
    