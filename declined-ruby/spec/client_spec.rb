# frozen_string_literal: true

require 'spec_helper'
require 'declined'

RSpec.describe Declined::Client do
  let(:api_key) { 'decl_live_sk_test_key' }
  let(:base_url) { Declined::Paths::DEFAULT_BASE_URL }
  let(:client) { described_class.new(api_key, base_url: base_url) }

  {
    events: [:post, '/v1/events', :create, { event_id: 'evt_1', type: 'payment_failed', customer_id: 'cus_1' }],
    customers: [:get, '/v1/customers', :list, {}],
    recoveries: [:get, '/v1/recoveries', :list, {}],
    sequences: [:get, '/v1/sequences', :list, {}],
    webhooks: [:get, '/v1/webhooks', :list, {}],
    incentives: [:get, '/v1/incentives', :list, {}],
    analytics: [:get, '/v1/analytics', :get, {}],
    events_recovered: [:post, '/v1/events', :mark_payment_recovered, { event_id: 'evt_2', customer_id: 'cus_1', invoice_id: 'inv_1' }],
    recoveries_mark: [:post, '/v1/recoveries/ra_123/mark-recovered', :mark_recovered, ['ra_123']]
  }.each do |resource, (method, path, action, params)|
    it "#{method.upcase} #{path}" do
      stub_request(method, "#{base_url}#{path}")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: { data: [], has_more: false }.to_json, headers: { 'Content-Type' => 'application/json' })

      resource_name = resource.to_s.start_with?('events_') ? :events : (resource.to_s.start_with?('recoveries_') ? :recoveries : resource)
      if params.is_a?(Array)
        client.public_send(resource_name).public_send(action, *params)
      else
        client.public_send(resource_name).public_send(action, **params)
      end
    end
  end
end
