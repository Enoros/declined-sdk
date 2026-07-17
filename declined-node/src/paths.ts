export const API_PATHS = {
  events: "/v1/events",
  customers: "/v1/customers",
  recoveries: "/v1/recoveries",
  sequences: "/v1/sequences",
  webhooks: "/v1/webhooks",
  analytics: "/v1/analytics",
  incentives: "/v1/incentives",
} as const;

export function recoveryMarkRecoveredPath(id: string): string {
  return `/v1/recoveries/${id}/mark-recovered`;
}

export type ApiPath = (typeof API_PATHS)[keyof typeof API_PATHS];

export const DEFAULT_BASE_URL = "https://api.declined.io/api";

export function buildUrl(baseUrl: string, path: string): string {
  return `${baseUrl.replace(/\/$/, "")}${path}`;
}
