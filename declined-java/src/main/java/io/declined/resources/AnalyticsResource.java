package io.declined.resources;

import com.fasterxml.jackson.databind.JsonNode;
import io.declined.ApiPaths;
import io.declined.Declined;
import java.io.IOException;
import java.util.Map;

public final class AnalyticsResource extends ListResource {
  public AnalyticsResource(Declined client) {
    super(client, ApiPaths.ANALYTICS);
  }

  public JsonNode get(Map<String, String> params) throws IOException {
    return list(params);
  }
}
