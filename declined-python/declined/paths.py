API_PATHS = {
    "events": "/v1/events",
    "customers": "/v1/customers",
    "recoveries": "/v1/recoveries",
    "sequences": "/v1/sequences",
    "webhooks": "/v1/webhooks",
    "analytics": "/v1/analytics",
    "incentives": "/v1/incentives",
}

DEFAULT_BASE_URL = "https://api.declined.io/api"


def recovery_mark_recovered_path(recovery_attempt_id: str) -> str:
    return f"/v1/recoveries/{recovery_attempt_id}/mark-recovered"


def build_url(base_url: str, path: str) -> str:
    return f"{base_url.rstrip('/')}{path}"
