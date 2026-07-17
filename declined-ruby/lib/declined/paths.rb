# frozen_string_literal: true

module Declined
  module Paths
    API_PATHS = {
      events: '/v1/events',
      customers: '/v1/customers',
      recoveries: '/v1/recoveries',
      sequences: '/v1/sequences',
      webhooks: '/v1/webhooks',
      analytics: '/v1/analytics',
      incentives: '/v1/incentives'
    }.freeze

    def self.recovery_mark_recovered_path(id)
      "/v1/recoveries/#{id}/mark-recovered"
    end

    DEFAULT_BASE_URL = 'https://api.declined.io/api'

    def self.build_url(base_url, path)
      "#{base_url.to_s.chomp('/')}#{path}"
    end
  end
end
