import pytest

from src.console_app import ConsoleApp

def test_statement():
    app = ConsoleApp()
    app.login("testuser2", "password2") # TODO: Change to 1
    assert len(app.get_statements()) == 0

    app.update_cart(1, 1)
    app.purchase()

    statements = app.get_statements()
    assert len(statements) == 1
    statement = app.read_statement(statements[0])
    assert statement['_id'] == statements[0]
    assert statement['user_id'] == 8
    assert statement['purchase'] == {1: 1}

    app.update_cart(2, 2)
    app.purchase()
    
    assert len(app.get_statements()) == 2
    assert app.read_statement(999) == "Statement 999 does not belong to testuser2"

