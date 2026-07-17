import type { HttpClient } from "../client.js";
import { API_PATHS } from "../paths.js";
import type { ListParams } from "../types.js";

export class IncentivesResource {
  constructor(private readonly http: HttpClient) {}

  list(params?: ListParams) {
    return this.http.request("GET", API_PATHS.incentives, undefined, params);
  }
}
