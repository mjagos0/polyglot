import pytest

from src.console_app import fetch_products

def test_fetch_products():
    # No filter returns entire database
    result = fetch_products()
    assert len(result) == 100

    # price filter
    result = fetch_products({"price_min": "1000"})
    assert len(result) != 0
    for r in result:
        assert r[7] >= 1000

    result = fetch_products({"price_max": "1000"})
    assert len(result) != 0
    for r in result:
        assert r[7] <= 1000

    result = fetch_products({"price": "1069"})
    assert len(result) != 0
    for r in result:
        assert r[7] == 1069

    # id filter
    result = fetch_products({"id": 1})
    assert len(result) == 1 and result[0][0] == 1

    # vendor, product type and product condition filter
    result = fetch_products({"vendor": "HP", "product_type": "Refurbished Laptop", "product_condition": "Excellent"})
    assert len(result) != 0
    for r in result:
        assert r[1] == "HP" and r[2] == "Refurbished Laptop" and r[3] == "Excellent"

    # attributes
    result = fetch_products({"Operating system": "No OS"})
    assert len(result) != 0
    for r in result:
        assert r[8]["Operating system"]