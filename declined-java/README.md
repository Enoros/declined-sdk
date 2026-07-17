# declined-java

Official [Declined.io](https://declined.io) REST API client for Java.

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local dev: [http://localhost:3003](http://localhost:3003))

## Install

Maven:

```xml
<dependency>
  <groupId>io.declined</groupId>
  <artifactId>declined-java</artifactId>
  <version>1.0.0</version>
</dependency>
```

## Usage

```java
import io.declined.Declined;
import io.declined.model.EventCreateParams;

Declined client = Declined.builder()
  .apiKey("decl_live_sk_...")
  .baseUrl("https://api.declined.io/api")
  .build();

client.events().create(EventCreateParams.builder()
  .eventId("evt_example")
  .type("payment_failed")
  .customerId("cus_123")
  .build());
```

## Marking a payment as recovered

When a customer pays outside Declined's hosted flow, notify Declined so recovery sequences stop and analytics stay accurate.

**Option 1 — Event API (recommended):**

```java
client.events().markPaymentRecovered(EventCreateParams.builder()
  .eventId("evt_recovered")
  .customerId("cus_123")
  .invoiceId("inv_456")
  .build());
```

**Option 2 — Recovery attempt ID:**

```java
client.recoveries().markRecovered("ra_abc123");
```

See the [Recoveries guide](https://docs.declined.io/docs/recoveries) for details.

## Development

```bash
mvn test
```

## License

MIT
