# frozen_string_literal: true

module Declined
  class Error < StandardError
    attr_reader :status, :code

    def initialize(status, message, code = nil)
      super(message)
      @status = status
      @code = code
    end
  end
end
