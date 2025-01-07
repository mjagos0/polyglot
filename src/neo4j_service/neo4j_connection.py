from neo4j import GraphDatabase

class NEO4J_CONNECTION:
    NEO4J_PARAMS = {
        "uri": "bolt://localhost:7687",
        "auth": ("neo4j", "password"),
    }

    def __init__(self):
        self.client = self.connect()

    def connect(self) -> GraphDatabase.driver:
        return GraphDatabase.driver(**self.NEO4J_PARAMS)