from __future__ import annotations

from typing import TYPE_CHECKING, Any

from declined.paths import API_PATHS

if TYPE_CHECKING:
    from declined.client import HttpTransport


class EventsResource:
    def __init__(self, http: HttpTransport):
        self._http = http

    def create(self, **params: Any) -> Any:
        return self._http.request("POST", API_PATHS["events"], body=params)

    def mark_payment_recovered(self, **params: Any) -> Any:
        return self.create(type="payment_recovered", **params)
