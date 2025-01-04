import psycopg2

class PSQL_CONNECTION:
    PSQL_PARAMS = {
        "host": "localhost",
        "database": "mydb",
        "user": "admin",
        "password": "password"
    }

    def __init__(self):
        self.connect()

    def connect(self):
        self.psql = psycopg2.connect(**self.PSQL_PARAMS)
        self.psql.autocommit = True

    def execute_query(self, query: str, params: dict) -> list:
        if not self.psql:
            raise ConnectionError("No active database connection.")
        if self.psql.closed == 0: # Refresh connection if it was closed
            self.connect()

        with self.psql.cursor() as cur:
            cur.execute(query, params)
            return cur.fetchall()
