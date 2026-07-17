import { describe, expect, it, vi } from "vitest";
import Declined, { API_PATHS, recoveryMarkRecoveredPath } from "../src/index.js";

const API_KEY = "decl_live_sk_test_key";

function mockFetch(handler: (url: string, init?: RequestInit) => { status: number; body?: unknown }) {
  return vi.fn(async (url: string, init?: RequestInit) => {
    const result = handler(url, init);
    return new Response(result.body !== undefined ? JSON.stringify(result.body) : "", {
      status: result.status,
      headers: { "Content-Type": "application/json" },
    });
  });
}

describe("Declined client", () => {
  it("POST /v1/events", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.events}`);
      expect(init?.method).toBe("POST");
      expect(init?.headers).toMatchObject({ Authorization: `Bearer ${API_KEY}` });
      return { status: 201, body: { id: "evt_1" } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.events.create({ event_id: "evt_1", type: "payment_failed", customer_id: "cus_1" });
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/customers", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.customers}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { data: [], has_more: false } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.customers.list();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/recoveries", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.recoveries}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { data: [], has_more: false } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.recoveries.list();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/sequences", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.sequences}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { data: [], has_more: false } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.sequences.list();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/webhooks", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.webhooks}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { data: [], has_more: false } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.webhooks.list();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/incentives", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.incentives}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { data: [], has_more: false } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.incentives.list();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("GET /v1/analytics", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.analytics}`);
      expect(init?.method).toBe("GET");
      return { status: 200, body: { recovery_rate: 0.42 } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.analytics.get();
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("POST /v1/events payment_recovered", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${API_PATHS.events}`);
      expect(init?.method).toBe("POST");
      expect(JSON.parse(String(init?.body))).toMatchObject({
        type: "payment_recovered",
        customer_id: "cus_1",
        invoice_id: "inv_1",
      });
      return { status: 201, body: { id: "evt_2" } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.events.markPaymentRecovered({
      event_id: "evt_2",
      customer_id: "cus_1",
      invoice_id: "inv_1",
    });
    expect(fetchFn).toHaveBeenCalledOnce();
  });

  it("POST /v1/recoveries/:id/mark-recovered", async () => {
    const fetchFn = mockFetch((url, init) => {
      expect(url).toBe(`https://api.declined.io/api${recoveryMarkRecoveredPath("ra_123")}`);
      expect(init?.method).toBe("POST");
      return { status: 200, body: { recovery_attempt_id: "ra_123", status: "recovered" } };
    });
    const client = new Declined(API_KEY, { fetch: fetchFn });
    await client.recoveries.markRecovered("ra_123");
    expect(fetchFn).toHaveBeenCalledOnce();
  });
});
