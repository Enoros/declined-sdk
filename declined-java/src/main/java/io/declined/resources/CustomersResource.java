package io.declined.resources;

import io.declined.ApiPaths;
import io.declined.Declined;

public final class CustomersResource extends ListResource {
  public CustomersResource(Declined client) {
    super(client, ApiPaths.CUSTOMERS);
  }
}
