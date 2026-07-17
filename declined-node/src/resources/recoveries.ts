import type { HttpClient } from "../client.js";
import { API_PATHS, recoveryMarkRecoveredPath } from "../paths.js";
import type { ListParams } from "../types.js";

export class RecoveriesResource {
  constructor(private readonly http: HttpClient) {}

  list(params?: ListParams) {
    return this.http.request("GET", API_PATHS.recoveries, undefined, params);
  }

  markRecovered(recoveryAttemptId: string) {
    return this.http.request("POST", recoveryMarkRecoveredPath(recoveryAttemptId));
  }
}
