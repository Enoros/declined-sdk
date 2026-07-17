from __future__ import annotations

from typing import TYPE_CHECKING, Any

from declined.paths import API_PATHS

if TYPE_CHECKING:
    from declined.client import HttpTransport


class WebhooksResource:
    def __init__(self, http: HttpTransport):
        self._http = http

    def list(self, **params: Any) -> Any:
        return self._http.request("GET", API_PATHS["webhooks"], params=params or None)
