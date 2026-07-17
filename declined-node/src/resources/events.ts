import type { HttpClient } from "../client.js";
import { API_PATHS } from "../paths.js";
import type { EventCreateParams } from "../types.js";

export class EventsResource {
  constructor(private readonly http: HttpClient) {}

  create(params: EventCreateParams) {
    return this.http.request("POST", API_PATHS.events, params);
  }

  markPaymentRecovered(params: Omit<EventCreateParams, "type">) {
    return this.create({ ...params, type: "payment_recovered" });
  }
}
