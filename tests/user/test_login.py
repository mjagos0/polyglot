import pytest

from src.console_app import ConsoleApp

def test_login():
    app = ConsoleApp()
    assert app.active_user is None and app.active_session is None and app.active_cart is None
    assert app.login("testuser1", "password1") == "Welcome back testuser1"
    assert app.active_user == "testuser1" and app.active_session is not None and app.active_cart is not None and app.active_user_id == 7 and not app.is_admin
    assert app.logout() == "User testuser1 logged out"
    assert app.active_user is None and app.active_session is None and app.active_cart is None and app.active_user_id == -1 and not app.is_admin
    assert app.login("testuser1", "wrongpassword") == "Incorrect credentials"
    assert app.active_user is None and app.active_session is None and app.active_cart is None and app.active_user_id == -1 and not app.is_admin
    assert app.login("nonexistinguser", "password") == "Incorrect credentials"
    assert app.active_user is None and app.active_session is None and app.active_cart is None and app.active_user_id == -1 and not app.is_admin
