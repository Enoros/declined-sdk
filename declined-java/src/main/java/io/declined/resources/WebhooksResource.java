package io.declined.resources;

import io.declined.ApiPaths;
import io.declined.Declined;

public final class WebhooksResource extends ListResource {
  public WebhooksResource(Declined client) {
    super(client, ApiPaths.WEBHOOKS);
  }
}
