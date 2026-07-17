package io.declined;

import com.fasterxml.jackson.databind.JsonNode;
import io.declined.model.EventCreateParams;
import java.util.Map;
import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import okhttp3.mockwebserver.RecordedRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DeclinedClientTest {
  private static final String API_KEY = "decl_live_sk_test_key";
  private MockWebServer server;

  @BeforeEach
  void setUp() throws Exception {
    server = new MockWebServer();
    server.start();
  }

  @AfterEach
  void tearDown() throws Exception {
    server.shutdown();
  }

  private Declined client() {
    return Declined.builder()
        .apiKey(API_KEY)
        .baseUrl(server.url("/api").toString().replaceAll("/$", ""))
        .build();
  }

  private void enqueueOk() {
    server.enqueue(new MockResponse().setBody("{\"data\":[],\"has_more\":false}").addHeader("Content-Type", "application/json"));
  }

  @Test
  void postEvents() throws Exception {
    enqueueOk();
    client().events().create(EventCreateParams.builder()
        .eventId("evt_1").type("payment_failed").customerId("cus_1").build());
    RecordedRequest req = server.takeRequest();
    assertEquals("POST", req.getMethod());
    assertEquals("/api/v1/events", req.getPath());
    assertEquals("Bearer " + API_KEY, req.getHeader("Authorization"));
  }

  @Test void getCustomers() throws Exception { testGet("/v1/customers", c -> c.customers().list(Map.of())); }
  @Test void getRecoveries() throws Exception { testGet("/v1/recoveries", c -> c.recoveries().list(Map.of())); }
  @Test void getSequences() throws Exception { testGet("/v1/sequences", c -> c.sequences().list(Map.of())); }
  @Test void getWebhooks() throws Exception { testGet("/v1/webhooks", c -> c.webhooks().list(Map.of())); }
  @Test void getIncentives() throws Exception { testGet("/v1/incentives", c -> c.incentives().list(Map.of())); }
  @Test void getAnalytics() throws Exception { testGet("/v1/analytics", c -> c.analytics().get(Map.of())); }

  @Test
  void postPaymentRecovered() throws Exception {
    enqueueOk();
    client().events().markPaymentRecovered(EventCreateParams.builder()
        .eventId("evt_2").customerId("cus_1").invoiceId("inv_1").build());
    RecordedRequest req = server.takeRequest();
    assertEquals("POST", req.getMethod());
    assertEquals("/api/v1/events", req.getPath());
    assertEquals("Bearer " + API_KEY, req.getHeader("Authorization"));
  }

  @Test
  void postMarkRecovered() throws Exception {
    enqueueOk();
    client().recoveries().markRecovered("ra_123");
    RecordedRequest req = server.takeRequest();
    assertEquals("POST", req.getMethod());
    assertEquals("/api/v1/recoveries/ra_123/mark-recovered", req.getPath());
    assertEquals("Bearer " + API_KEY, req.getHeader("Authorization"));
  }

  private void testGet(String path, RequestCall call) throws Exception {
    enqueueOk();
    call.run(client());
    RecordedRequest req = server.takeRequest();
    assertEquals("GET", req.getMethod());
    assertEquals("/api" + path, req.getPath());
    assertEquals("Bearer " + API_KEY, req.getHeader("Authorization"));
  }

  @FunctionalInterface
  interface RequestCall {
    void run(Declined client) throws Exception;
  }
}
