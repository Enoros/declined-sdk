# declined-io (Ruby)

Official [Declined.io](https://declined.io) REST API client for Ruby.

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

```bash
gem install declined-io
```

## Usage

```ruby
require 'declined'

client = Declined::Client.new('decl_live_sk_...', base_url: 'https://api.declined.io/api')

client.events.create(
  event_id: "evt_#{Time.now.to_i}",
  type: 'payment_failed',
  customer_id: 'cus_123',
  invoice_id: 'inv_456',
  amount: 24900,
  currency: 'usd',
  provider: 'stripe'
)

client.customers.list
client.recoveries.list
client.sequences.list
client.webhooks.list
client.incentives.list
client.analytics.get
```

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```ruby
client.events.mark_payment_recovered(
  event_id: "evt_#{Time.now.to_i}",
  customer_id: 'cus_123',
  invoice_id: 'inv_456',
)
```

**Option 2 — Recovery attempt ID:**

```ruby
client.recoveries.mark_recovered('ra_abc123')
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Development

```bash
bundle install
bundle exec rspec
```

## License

MIT
