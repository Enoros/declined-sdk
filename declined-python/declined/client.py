from __future__ import annotations

import json
from typing import Any
from urllib.parse import urlencode

import urllib3

from declined.exceptions import DeclinedError
from declined.paths import DEFAULT_BASE_URL, build_url
from declined.resources.analytics import AnalyticsResource
from declined.resources.customers import CustomersResource
from declined.resources.events import EventsResource
from declined.resources.incentives import IncentivesResource
from declined.resources.recoveries import RecoveriesResource
from declined.resources.sequences import SequencesResource
from declined.resources.webhooks import WebhooksResource


class HttpTransport:
    def __init__(self, api_key: str, base_url: str, http: urllib3.PoolManager | None = None):
        self._api_key = api_key
        self._base_url = base_url
        self._http = http or urllib3.PoolManager()

    def request(
        self,
        method: str,
        path: str,
        body: dict[str, Any] | None = None,
        params: dict[str, Any] | None = None,
    ) -> Any:
        url = build_url(self._base_url, path)
        if params:
            query = urlencode({k: v for k, v in params.items() if v is not None})
            if query:
                url = f"{url}?{query}"

        headers = {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        encoded = json.dumps(body).encode("utf-8") if body is not None else None
        response = self._http.request(method, url, body=encoded, headers=headers)
        text = response.data.decode("utf-8") if response.data else ""
        data = json.loads(text) if text else None

        if response.status >= 400:
            err = (data or {}).get("error", {})
            raise DeclinedError(
                response.status,
                err.get("message", f"Request failed with status {response.status}"),
                err.get("code"),
            )
        return data


class Declined:
    def __init__(self, api_key: str, base_url: str = DEFAULT_BASE_URL, http: urllib3.PoolManager | None = None):
        if not api_key:
            raise ValueError("API key is required")
        transport = HttpTransport(api_key, base_url, http)
        self.events = EventsResource(transport)
        self.customers = CustomersResource(transport)
        self.recoveries = RecoveriesResource(transport)
        self.sequences = SequencesResource(transport)
        self.webhooks = WebhooksResource(transport)
        self.incentives = IncentivesResource(transport)
        self.analytics = AnalyticsResource(transport)
