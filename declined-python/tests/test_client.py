import json
from unittest.mock import MagicMock

import pytest

from declined import Declined
from declined.paths import API_PATHS, DEFAULT_BASE_URL, recovery_mark_recovered_path

API_KEY = "decl_live_sk_test_key"
BASE = DEFAULT_BASE_URL


def make_http(status: int, body: dict):
    http = MagicMock()
    response = MagicMock()
    response.status = status
    response.data = json.dumps(body).encode("utf-8")
    http.request.return_value = response
    return http


@pytest.mark.parametrize(
    "resource,method,path,http_method,kwargs",
    [
        ("events", "create", API_PATHS["events"], "POST", {"event_id": "evt_1", "type": "payment_failed", "customer_id": "cus_1"}),
        ("customers", "list", API_PATHS["customers"], "GET", {}),
        ("recoveries", "list", API_PATHS["recoveries"], "GET", {}),
        ("sequences", "list", API_PATHS["sequences"], "GET", {}),
        ("webhooks", "list", API_PATHS["webhooks"], "GET", {}),
        ("incentives", "list", API_PATHS["incentives"], "GET", {}),
        ("analytics", "get", API_PATHS["analytics"], "GET", {}),
        ("events", "mark_payment_recovered", API_PATHS["events"], "POST", {
            "event_id": "evt_2",
            "customer_id": "cus_1",
            "invoice_id": "inv_1",
        }),
        ("recoveries", "mark_recovered", recovery_mark_recovered_path("ra_123"), "POST", {"recovery_attempt_id": "ra_123"}),
    ],
)
def test_api_calls(resource, method, path, http_method, kwargs):
    http = make_http(200, {"data": [], "has_more": False})
    client = Declined(API_KEY, http=http)
    if resource == "recoveries" and method == "mark_recovered":
        client.recoveries.mark_recovered(kwargs.pop("recovery_attempt_id"))
    else:
        getattr(getattr(client, resource), method)(**kwargs)
    call = http.request.call_args
    assert call[0][0] == http_method
    assert call[0][1] == f"{BASE}{path}"
    headers = call[1]["headers"]
    assert headers["Authorization"] == f"Bearer {API_KEY}"
