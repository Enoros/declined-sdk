# frozen_string_literal: true

require 'json'
require 'faraday'
require 'declined/paths'
require 'declined/error'
require 'declined/resources/events'
require 'declined/resources/customers'
require 'declined/resources/recoveries'
require 'declined/resources/sequences'
require 'declined/resources/webhooks'
require 'declined/resources/incentives'
require 'declined/resources/analytics'

module Declined
  class Client
    attr_reader :events, :customers, :recoveries, :sequences, :webhooks, :incentives, :analytics

    def initialize(api_key, base_url: Paths::DEFAULT_BASE_URL, connection: nil)
      raise ArgumentError, 'API key is required' if api_key.nil? || api_key.empty?

      @api_key = api_key
      @base_url = base_url
      @connection = connection || Faraday.new do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end

      @events = Resources::Events.new(self)
      @customers = Resources::Customers.new(self)
      @recoveries = Resources::Recoveries.new(self)
      @sequences = Resources::Sequences.new(self)
      @webhooks = Resources::Webhooks.new(self)
      @incentives = Resources::Incentives.new(self)
      @analytics = Resources::Analytics.new(self)
    end

    def request(method, path, body: nil, params: nil)
      url = Paths.build_url(@base_url, path)
      response = @connection.run_request(method, url, body, {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }) do |req|
        req.params.update(params) if params
      end

      unless response.success?
        err = response.body.is_a?(Hash) ? response.body['error'] : nil
        raise Error.new(
          response.status,
          err&.dig('message') || "Request failed with status #{response.status}",
          err&.dig('code')
        )
      end

      response.body
    end
  end
end
