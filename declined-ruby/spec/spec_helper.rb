# frozen_string_literal: true

require 'webmock/rspec'
require 'declined'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
