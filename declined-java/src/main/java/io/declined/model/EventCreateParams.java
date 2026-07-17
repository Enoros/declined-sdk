package io.declined.model;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

public record EventCreateParams(
    String eventId,
    String type,
    String customerId,
    String invoiceId,
    Long amount,
    String currency,
    String provider,
    Map<String, Object> metadata) {

  public EventCreateParams withType(String newType) {
    return new EventCreateParams(eventId, newType, customerId, invoiceId, amount, currency, provider, metadata);
  }

  public static Builder builder() {
    return new Builder();
  }

  public static final class Builder {
    private String eventId;
    private String type;
    private String customerId;
    private String invoiceId;
    private Long amount;
    private String currency;
    private String provider;
    private Map<String, Object> metadata;

    public Builder eventId(String eventId) {
      this.eventId = eventId;
      return this;
    }

    public Builder type(String type) {
      this.type = type;
      return this;
    }

    public Builder customerId(String customerId) {
      this.customerId = customerId;
      return this;
    }

    public Builder invoiceId(String invoiceId) {
      this.invoiceId = invoiceId;
      return this;
    }

    public Builder amount(Long amount) {
      this.amount = amount;
      return this;
    }

    public Builder currency(String currency) {
      this.currency = currency;
      return this;
    }

    public Builder provider(String provider) {
      this.provider = provider;
      return this;
    }

    public Builder metadata(Map<String, Object> metadata) {
      this.metadata = metadata;
      return this;
    }

    public EventCreateParams build() {
      return new EventCreateParams(eventId, type, customerId, invoiceId, amount, currency, provider, metadata);
    }
  }

  public JsonNode toJson(com.fasterxml.jackson.databind.ObjectMapper mapper) {
    var node = mapper.createObjectNode();
    node.put("event_id", eventId);
    node.put("type", type);
    node.put("customer_id", customerId);
    if (invoiceId != null) node.put("invoice_id", invoiceId);
    if (amount != null) node.put("amount", amount);
    if (currency != null) node.put("currency", currency);
    if (provider != null) node.put("provider", provider);
    if (metadata != null) node.set("metadata", mapper.valueToTree(metadata));
    return node;
  }
}
