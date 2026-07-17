import type { HttpClient } from "../client.js";
import { API_PATHS } from "../paths.js";
import type { ListParams } from "../types.js";

export class AnalyticsResource {
  constructor(private readonly http: HttpClient) {}

  get(params?: ListParams) {
    return this.http.request("GET", API_PATHS.analytics, undefined, params);
  }
}
