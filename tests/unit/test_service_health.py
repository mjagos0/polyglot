import pytest

from src.console_app import ConsoleApp

def test_service_health():
    app = ConsoleApp();

    app.psql_health == app._check_service_health("PSQL") == True
    app.psql_health == app._check_service_health("REDIS") == True
    app.psql_health == app._check_service_health("MONGODB") == True
    app.psql_health == app._check_service_health("CASSANDRA") == True
