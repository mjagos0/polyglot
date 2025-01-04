import pytest

from src.console_app import ConsoleApp

def test_session():
    app = ConsoleApp();
    session1 = app._create_session(6)
    assert app._user_has_active_session(6)
    assert app._session_exists(session1)
    assert not app._user_has_active_session(7)
    session2 = app._create_session(7)
    assert app._user_has_active_session(7)
    assert app._session_exists(session2)
    app._drop_session(7)
    app._drop_session(6)
    assert not app._user_has_active_session(6)
    assert not app._user_has_active_session(7)
    assert not app._session_exists(session1)
    assert not app._session_exists(session2)
    assert not app._session_exists("RandomSession")

def test_cart():
    app = ConsoleApp();
    app._drop_cart(6)
    assert not app._user_cart_exists(6)
    assert not app._get_user_cart(6)
    assert (cart_id := app._create_cart(6))
    assert app._user_cart_exists(6)
    assert app._get_user_cart(6) == cart_id
    app._drop_cart(6)
    assert not app._user_cart_exists(6)
    assert not app._get_user_cart(6)
    assert (cart_id := app._create_cart(6))
    assert app._user_cart_exists(6)
    assert app._get_user_cart(6) == cart_id

    assert app._cart_update(6, 0, 1) == {0: 1}
    assert app._cart_update(6, 0, 1) == {0: 2}
    assert app._cart_update(6, 0, -2) == {}
    assert app._cart_update(6, 1, 2) == {1: 2}
    assert app._cart_update(6, 2, 3) == {1: 2, 2: 3}
    assert app._cart_read(6) == {1: 2, 2: 3}
    app._drop_cart(6)
    assert (cart_id := app._create_cart(6))
    assert app._cart_read(6) == {}
    app._drop_cart(6)






