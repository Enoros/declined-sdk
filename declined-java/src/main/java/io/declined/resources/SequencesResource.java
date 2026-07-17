package io.declined.resources;

import io.declined.ApiPaths;
import io.declined.Declined;

public final class SequencesResource extends ListResource {
  public SequencesResource(Declined client) {
    super(client, ApiPaths.SEQUENCES);
  }
}
