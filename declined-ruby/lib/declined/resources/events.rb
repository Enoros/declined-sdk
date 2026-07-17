# frozen_string_literal: true

module Declined
  module Resources
    class Base
      def initialize(client)
        @client = client
      end
    end

    class Events < Base
      def create(params)
        @client.request(:post, Paths::API_PATHS[:events], body: params)
      end

      def mark_payment_recovered(params)
        create(params.merge(type: 'payment_recovered'))
      end
    end

    class Customers < Base
      def list(params = {})
        @client.request(:get, Paths::API_PATHS[:customers], params: params)
      end
    end

    class Recoveries < Base
      def list(params = {})
        @client.request(:get, Paths::API_PATHS[:recoveries], params: params)
      end

      def mark_recovered(recovery_attempt_id)
        @client.request(:post, Paths.recovery_mark_recovered_path(recovery_attempt_id))
      end
    end

    class Sequences < Base
      def list(params = {})
        @client.request(:get, Paths::API_PATHS[:sequences], params: params)
      end
    end

    class Webhooks < Base
      def list(params = {})
        @client.request(:get, Paths::API_PATHS[:webhooks], params: params)
      end
    end

    class Incentives < Base
      def list(params = {})
        @client.request(:get, Paths::API_PATHS[:incentives], params: params)
      end
    end

    class Analytics < Base
      def get(params = {})
        @client.request(:get, Paths::API_PATHS[:analytics], params: params)
      end
    end
  end
end
