import pytest
from datetime import datetime, timezone, timedelta

from src.console_app import ConsoleApp

def test_log():
    app = ConsoleApp()
    assert len(app._read_log(6)) == 0
    assert app._create_log(6, "TestAction", {"param1": 1, "param2": "value2"}, ["TestTag1", "TestTag2"])
    log = app._read_log(6)
    assert len(log) == 1
    log = log[0]
    assert log["userId"] == 6
    assert abs(datetime.now(timezone.utc) - datetime.strptime(log['timestamp'], "%a, %d %b %Y %H:%M:%S %Z").replace(tzinfo=timezone.utc)) <= timedelta(minutes=1)
    assert log["action"] == "TestAction"
    assert log["parameters"] == {"param1": "1", "param2": "value2"}
    assert log["tags"] == ["TestTag1", "TestTag2"]

    assert app._create_log(7, "TestAction1", {"param1": 1, "param2": "value2"}, ["TestTag1", "TestTag2"])
    assert len(app._read_log(6)) == 1
    assert app._create_log(6, "TestAction2", {"param1": 1, "param2": "value2"}, ["TestTag1", "TestTag2"])
    log = app._read_log(6)
    assert len(app._read_log(6)) == 2
