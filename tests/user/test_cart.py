import pytest

from src.console_app import ConsoleApp

def test_cart():
    app = ConsoleApp()
    app.login("testuser1", "password1")
    app.clear_cart() # TODO: Remove
    assert app.read_cart() == {}
    assert app.update_cart(1, 1) == {1: 1}
    assert app.update_cart(1, 2) == {1: 3}
    assert app.update_cart(2, 1) == {1: 3, 2: 1}
    assert app.update_cart(2, -1) == {1: 3}
    assert app.update_cart(3, 0) == {1: 3}
    assert app.read_cart() == {1: 3}
    assert app.clear_cart() == {}
    assert app.update_cart(3, 3) == {3: 3}
    assert app.purchase()
    assert app.read_cart() == {}
