package io.declined.resources;

import io.declined.ApiPaths;
import io.declined.Declined;

public final class IncentivesResource extends ListResource {
  public IncentivesResource(Declined client) {
    super(client, ApiPaths.INCENTIVES);
  }
}
