package io.declined.resources;

import com.fasterxml.jackson.databind.JsonNode;
import io.declined.ApiPaths;
import io.declined.Declined;
import java.io.IOException;
import java.util.Map;

public final class RecoveriesResource {
  private final Declined client;

  public RecoveriesResource(Declined client) {
    this.client = client;
  }

  public JsonNode list(Map<String, String> params) throws IOException {
    return client.request("GET", ApiPaths.RECOVERIES, null, params);
  }

  public JsonNode markRecovered(String recoveryAttemptId) throws IOException {
    return client.request("POST", ApiPaths.recoveryMarkRecovered(recoveryAttemptId), null, null);
  }
}
