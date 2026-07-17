from __future__ import annotations

from typing import TYPE_CHECKING, Any

from declined.paths import API_PATHS, recovery_mark_recovered_path

if TYPE_CHECKING:
    from declined.client import HttpTransport


class RecoveriesResource:
    def __init__(self, http: HttpTransport):
        self._http = http

    def list(self, **params: Any) -> Any:
        return self._http.request("GET", API_PATHS["recoveries"], params=params or None)

    def mark_recovered(self, recovery_attempt_id: str) -> Any:
        return self._http.request(
            "POST",
            recovery_mark_recovered_path(recovery_attempt_id),
        )
