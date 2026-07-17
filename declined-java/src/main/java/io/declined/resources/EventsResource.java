package io.declined.resources;

import com.fasterxml.jackson.databind.JsonNode;
import io.declined.ApiPaths;
import io.declined.Declined;
import io.declined.model.EventCreateParams;
import java.io.IOException;

public final class EventsResource {
  private final Declined client;

  public EventsResource(Declined client) {
    this.client = client;
  }

  public JsonNode create(EventCreateParams params) throws IOException {
    return client.request("POST", ApiPaths.EVENTS, params.toJson(client.mapper()), null);
  }

  public JsonNode markPaymentRecovered(EventCreateParams params) throws IOException {
    return create(params.withType("payment_recovered"));
  }
}
