# declined-go

Official [Declined.io](https://declined.io) REST API client for Go.

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

```bash
go get github.com/declined-io/declined-go
```

## Usage

```go
package main

import (
  "context"
  declined "github.com/declined-io/declined-go"
)

func main() {
  client := declined.New("decl_live_sk_...", declined.WithBaseURL("https://api.declined.io/api"))
  _, err := client.Events.Create(context.Background(), declined.EventCreateParams{
    EventID: "evt_example", Type: "payment_failed", CustomerID: "cus_123",
  })
  if err != nil { panic(err) }
}
```

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```go
_, err := client.Events.MarkPaymentRecovered(context.Background(), declined.EventCreateParams{
  EventID: "evt_recovered", CustomerID: "cus_123", InvoiceID: "inv_456",
})
```

**Option 2 — Recovery attempt ID:**

```go
_, err := client.Recoveries.MarkRecovered(context.Background(), "ra_abc123")
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Development

```bash
go test ./...
```

## License

MIT
