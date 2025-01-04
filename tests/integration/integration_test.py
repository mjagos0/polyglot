import pytest

from src.console_app import ConsoleApp

def test_app():
    app = ConsoleApp()
    assert app.login("testuser1", "password1") == "Welcome back testuser1"
    assert app.read_cart() == {}
    assert app.update_cart(5, 1) == {5: 1}
    assert app.read_cart() == {5: 1}
    assert (statementId := app.purchase())
    assert (statement := app.read_statement(statementId))
    assert statement['user_id'] == 7
    assert statement['purchase'] == {5: 1}
    
    assert app.update_cart(1, 1) == {1: 1}
    assert app.logout() == "User testuser1 logged out"
    assert app.login("testuser1", "password1") == "Welcome back testuser1"
    assert app.read_cart() == {1: 1}
    assert app.read_statement(statementId)