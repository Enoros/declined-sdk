import { API_PATHS, buildUrl, DEFAULT_BASE_URL } from "./paths.js";
import type { DeclinedOptions, ListParams } from "./types.js";
import { DeclinedError } from "./types.js";
import { AnalyticsResource } from "./resources/analytics.js";
import { CustomersResource } from "./resources/customers.js";
import { EventsResource } from "./resources/events.js";
import { IncentivesResource } from "./resources/incentives.js";
import { RecoveriesResource } from "./resources/recoveries.js";
import { SequencesResource } from "./resources/sequences.js";
import { WebhooksResource } from "./resources/webhooks.js";

export type HttpClient = {
  request<T>(method: string, path: string, body?: unknown, query?: ListParams): Promise<T>;
};

export class HttpTransport implements HttpClient {
  constructor(
    private readonly apiKey: string,
    private readonly baseUrl: string,
    private readonly fetchFn: typeof fetch,
  ) {}

  async request<T>(method: string, path: string, body?: unknown, query?: ListParams): Promise<T> {
    const url = new URL(buildUrl(this.baseUrl, path));
    if (query) {
      for (const [key, value] of Object.entries(query)) {
        if (value !== undefined) url.searchParams.set(key, String(value));
      }
    }

    const response = await this.fetchFn(url.toString(), {
      method,
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });

    const text = await response.text();
    const data = text ? (JSON.parse(text) as unknown) : undefined;

    if (!response.ok) {
      const err = data as { error?: { code?: string; message?: string; details?: Record<string, unknown> } };
      throw new DeclinedError(
        response.status,
        err?.error?.message ?? `Request failed with status ${response.status}`,
        err?.error?.code,
        err?.error?.details,
      );
    }

    return data as T;
  }
}

export default class Declined {
  readonly events: EventsResource;
  readonly customers: CustomersResource;
  readonly recoveries: RecoveriesResource;
  readonly sequences: SequencesResource;
  readonly webhooks: WebhooksResource;
  readonly incentives: IncentivesResource;
  readonly analytics: AnalyticsResource;

  constructor(apiKey: string, options: DeclinedOptions = {}) {
    if (!apiKey) throw new Error("API key is required");
    const transport = new HttpTransport(
      apiKey,
      options.baseUrl ?? DEFAULT_BASE_URL,
      options.fetch ?? fetch,
    );
    this.events = new EventsResource(transport);
    this.customers = new CustomersResource(transport);
    this.recoveries = new RecoveriesResource(transport);
    this.sequences = new SequencesResource(transport);
    this.webhooks = new WebhooksResource(transport);
    this.incentives = new IncentivesResource(transport);
    this.analytics = new AnalyticsResource(transport);
  }
}

export { API_PATHS, DEFAULT_BASE_URL, buildUrl, recoveryMarkRecoveredPath } from "./paths.js";
export type { DeclinedOptions, EventCreateParams, ListParams } from "./types.js";
export { DeclinedError } from "./types.js";
