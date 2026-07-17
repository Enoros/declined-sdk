# @declined/node

Official [Declined.io](https://declined.io) REST API client for Node.js (TypeScript).

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

```bash
npm install @declined/node
```

## Usage

```typescript
import Declined from "@declined/node";

const client = new Declined("decl_live_sk_...", {
  baseUrl: "https://api.declined.io/api",
});

await client.events.create({
  event_id: "evt_" + Date.now(),
  type: "payment_failed",
  customer_id: "cus_123",
  invoice_id: "inv_456",
  amount: 24900,
  currency: "usd",
  provider: "stripe",
});

const customers = await client.customers.list();
const recoveries = await client.recoveries.list();
const sequences = await client.sequences.list();
const webhooks = await client.webhooks.list();
const incentives = await client.incentives.list();
const analytics = await client.analytics.get();
```

## Authentication

Pass your secret API key (`decl_live_sk_*` or `decl_sandbox_sk_*`) as the first constructor argument. The client sends `Authorization: Bearer <key>` on every request.

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```typescript
await client.events.markPaymentRecovered({
  event_id: "evt_" + Date.now(),
  customer_id: "cus_123",
  invoice_id: "inv_456",
  amount: 24900,
  currency: "usd",
  provider: "stripe",
});
```

**Option 2 — Recovery attempt ID:**

```typescript
await client.recoveries.markRecovered("ra_abc123");
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Configuration

| Option    | Default                        | Description              |
|-----------|--------------------------------|--------------------------|
| `baseUrl` | `https://api.declined.io/api`  | API base URL with `/api` |

## Development

```bash
npm install
npm test
npm run build
```

## License

MIT
