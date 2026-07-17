package io.declined.resources;

import com.fasterxml.jackson.databind.JsonNode;
import io.declined.Declined;
import java.io.IOException;
import java.util.Map;

abstract class ListResource {
  private final Declined client;
  private final String path;

  ListResource(Declined client, String path) {
    this.client = client;
    this.path = path;
  }

  public JsonNode list(Map<String, String> params) throws IOException {
    return client.request("GET", path, null, params);
  }
}
