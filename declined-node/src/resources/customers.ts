import type { HttpClient } from "../client.js";
import { API_PATHS } from "../paths.js";
import type { ListParams } from "../types.js";

export class CustomersResource {
  constructor(private readonly http: HttpClient) {}

  list(params?: ListParams) {
    return this.http.request("GET", API_PATHS.customers, undefined, params);
  }
}
