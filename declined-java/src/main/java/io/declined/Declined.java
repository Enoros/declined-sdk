package io.declined;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.declined.resources.AnalyticsResource;
import io.declined.resources.CustomersResource;
import io.declined.resources.EventsResource;
import io.declined.resources.IncentivesResource;
import io.declined.resources.RecoveriesResource;
import io.declined.resources.SequencesResource;
import io.declined.resources.WebhooksResource;
import java.io.IOException;
import java.util.Map;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public final class Declined {
  private final String apiKey;
  private final String baseUrl;
  private final OkHttpClient http;
  private final ObjectMapper mapper;

  private final EventsResource events;
  private final CustomersResource customers;
  private final RecoveriesResource recoveries;
  private final SequencesResource sequences;
  private final WebhooksResource webhooks;
  private final IncentivesResource incentives;
  private final AnalyticsResource analytics;

  private Declined(Builder builder) {
    this.apiKey = builder.apiKey;
    this.baseUrl = builder.baseUrl;
    this.http = builder.http;
    this.mapper = builder.mapper;
    this.events = new EventsResource(this);
    this.customers = new CustomersResource(this);
    this.recoveries = new RecoveriesResource(this);
    this.sequences = new SequencesResource(this);
    this.webhooks = new WebhooksResource(this);
    this.incentives = new IncentivesResource(this);
    this.analytics = new AnalyticsResource(this);
  }

  public static Builder builder() {
    return new Builder();
  }

  public EventsResource events() {
    return events;
  }

  public CustomersResource customers() {
    return customers;
  }

  public RecoveriesResource recoveries() {
    return recoveries;
  }

  public SequencesResource sequences() {
    return sequences;
  }

  public WebhooksResource webhooks() {
    return webhooks;
  }

  public IncentivesResource incentives() {
    return incentives;
  }

  public AnalyticsResource analytics() {
    return analytics;
  }

  public JsonNode request(String method, String path, JsonNode body, Map<String, String> query) throws IOException {
    HttpUrl.Builder urlBuilder = HttpUrl.parse(ApiPaths.buildUrl(baseUrl, path)).newBuilder();
    if (query != null) {
      query.forEach((k, v) -> {
        if (v != null) urlBuilder.addQueryParameter(k, v);
      });
    }

    Request.Builder reqBuilder =
        new Request.Builder()
            .url(urlBuilder.build())
            .header("Authorization", "Bearer " + apiKey)
            .header("Accept", "application/json");

    if (body != null) {
      reqBuilder
          .method(method, RequestBody.create(body.toString(), MediaType.get("application/json")))
          .header("Content-Type", "application/json");
    } else if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "PATCH".equalsIgnoreCase(method)) {
      reqBuilder
          .method(method, RequestBody.create("{}", MediaType.get("application/json")))
          .header("Content-Type", "application/json");
    } else {
      reqBuilder.method(method, null);
    }

    try (Response response = http.newCall(reqBuilder.build()).execute()) {
      String text = response.body() != null ? response.body().string() : "";
      JsonNode data = text.isEmpty() ? mapper.createObjectNode() : mapper.readTree(text);
      if (!response.isSuccessful()) {
        JsonNode err = data.path("error");
        throw new DeclinedException(
            response.code(),
            err.path("message").asText("Request failed with status " + response.code()),
            err.path("code").asText(null));
      }
      return data;
    }
  }

  public ObjectMapper mapper() {
    return mapper;
  }

  public static final class Builder {
    private String apiKey;
    private String baseUrl = ApiPaths.DEFAULT_BASE_URL;
    private OkHttpClient http = new OkHttpClient();
    private ObjectMapper mapper = new ObjectMapper();

    public Builder apiKey(String apiKey) {
      this.apiKey = apiKey;
      return this;
    }

    public Builder baseUrl(String baseUrl) {
      this.baseUrl = baseUrl;
      return this;
    }

    public Builder http(OkHttpClient http) {
      this.http = http;
      return this;
    }

    public Declined build() {
      if (apiKey == null || apiKey.isBlank()) {
        throw new IllegalArgumentException("API key is required");
      }
      return new Declined(this);
    }
  }
}
