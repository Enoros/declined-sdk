# declined-io (Python)

Official [Declined.io](https://declined.io) REST API client for Python.

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

```bash
pip install declined-io
```

## Usage

```python
from declined import Declined

client = Declined("decl_live_sk_...", base_url="https://api.declined.io/api")

client.events.create(
    event_id="evt_123",
    type="payment_failed",
    customer_id="cus_123",
    invoice_id="inv_456",
    amount=24900,
    currency="usd",
    provider="stripe",
)

customers = client.customers.list()
recoveries = client.recoveries.list()
sequences = client.sequences.list()
webhooks = client.webhooks.list()
incentives = client.incentives.list()
analytics = client.analytics.get()
```

## Authentication

Use your secret API key (`decl_live_sk_*` or `decl_sandbox_sk_*`). The client sends `Authorization: Bearer <key>` on every request.

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```python
client.events.mark_payment_recovered(
    event_id="evt_124",
    customer_id="cus_123",
    invoice_id="inv_456",
    amount=24900,
    currency="usd",
    provider="stripe",
)
```

**Option 2 — Recovery attempt ID:**

```python
client.recoveries.mark_recovered("ra_abc123")
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Development

```bash
pip install -e ".[dev]"
pytest
```

## License

MIT
