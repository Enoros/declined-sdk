export interface DeclinedOptions {
  baseUrl?: string;
  fetch?: typeof fetch;
}

export interface ListParams {
  limit?: number;
  starting_after?: string;
}

export interface EventCreateParams {
  event_id: string;
  type: string;
  customer_id: string;
  invoice_id?: string;
  amount?: number;
  currency?: string;
  provider?: string;
  metadata?: Record<string, unknown>;
}

export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}

export class DeclinedError extends Error {
  readonly status: number;
  readonly code?: string;
  readonly details?: Record<string, unknown>;

  constructor(status: number, message: string, code?: string, details?: Record<string, unknown>) {
    super(message);
    this.name = "DeclinedError";
    this.status = status;
    this.code = code;
    this.details = details;
  }
}
