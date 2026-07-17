package io.declined;

public final class ApiPaths {
  public static final String EVENTS = "/v1/events";
  public static final String CUSTOMERS = "/v1/customers";
  public static final String RECOVERIES = "/v1/recoveries";
  public static final String SEQUENCES = "/v1/sequences";
  public static final String WEBHOOKS = "/v1/webhooks";
  public static final String ANALYTICS = "/v1/analytics";
  public static final String INCENTIVES = "/v1/incentives";
  public static final String DEFAULT_BASE_URL = "https://api.declined.io/api";

  public static String recoveryMarkRecovered(String id) {
    return "/v1/recoveries/" + id + "/mark-recovered";
  }

  private ApiPaths() {}

  public static String buildUrl(String baseUrl, String path) {
    return baseUrl.replaceAll("/$", "") + path;
  }
}
