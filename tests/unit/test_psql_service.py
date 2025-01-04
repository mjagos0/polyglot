import pytest

from src.console_app import ConsoleApp

def test_is_admin():
    app = ConsoleApp()
    assert app._is_admin("admin")
    assert not app._is_admin("user1")
    assert not app._is_admin("testuser1")

def test_get_user_id():
    app = ConsoleApp()
    assert app._get_user_id("admin") == 1
    assert app._get_user_id("user1") == 2
    assert app._get_user_id("user2") == 3
    assert app._get_user_id("testuser1") == 7
    assert app._get_user_id("testuser3") == 9

def test_user_login():
    app = ConsoleApp()
    assert app._user_login("admin", "password")
    assert not app._user_login("admin", "wrongpassword")
    assert app._user_login("testuser1", "password1")
    assert not app._user_login("testuser1", "wrongpassword")

def test_fetch_products():
    app = ConsoleApp()
    assert len(app._fetch_products({})) != 0
    assert len(app._fetch_products({"product_type": "Refurbished Laptop"})) != len(app._fetch_products({}))