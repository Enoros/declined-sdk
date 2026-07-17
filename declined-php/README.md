# declined-io/sdk (PHP)

Official [Declined.io](https://declined.io) REST API client for PHP.

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

```bash
composer require declined-io/sdk
```

## Usage

```php
<?php
use Declined\Declined;

$client = new Declined('decl_live_sk_...', ['base_url' => 'https://api.declined.io/api']);

$client->events->create([
  'event_id' => 'evt_' . time(),
  'type' => 'payment_failed',
  'customer_id' => 'cus_123',
  'invoice_id' => 'inv_456',
  'amount' => 24900,
  'currency' => 'usd',
  'provider' => 'stripe',
]);

$client->customers->list();
$client->recoveries->list();
$client->sequences->list();
$client->webhooks->list();
$client->incentives->list();
$client->analytics->get();
```

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```php
$client->events->markPaymentRecovered([
  'event_id' => 'evt_' . time(),
  'customer_id' => 'cus_123',
  'invoice_id' => 'inv_456',
]);
```

**Option 2 — Recovery attempt ID:**

```php
$client->recoveries->markRecovered('ra_abc123');
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Development

```bash
composer install
composer test
```

## License

MIT
