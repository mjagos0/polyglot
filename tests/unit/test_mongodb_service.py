import pytest
from datetime import datetime, timezone, timedelta

from src.console_app import ConsoleApp

def test_statement():
    app = ConsoleApp()
    assert len(app._get_statements(6)) == 0
    assert app._create_statement(6, {0: 1, 7: 2})
    
    statements = app._get_statements(6)
    assert len(statements) == 1
    assert (statement := app._read_statement(statements[0]))
    assert statement['_id'] == statements[0]
    assert statement['user_id'] == 6
    assert statement['purchase'] == {0: 1, 7: 2}
    print(statement['creation_date'])
    assert abs(datetime.now(timezone.utc) - datetime.strptime(statement['creation_date'], "%a, %d %b %Y %H:%M:%S %Z").replace(tzinfo=timezone.utc)) <= timedelta(minutes=1)

    assert app._create_statement(7, {1: 1, 2: 2})
    assert len(app._get_statements(6)) == 1
    assert app._create_statement(6, {1: 1, 2: 2})
    assert len(app._get_statements(6)) == 2