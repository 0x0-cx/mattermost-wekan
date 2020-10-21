# frozen_string_literal: true

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
ENV['APP_ENV'] = 'test'
require 'bundler/setup'
Bundler.require(:test)

require 'support/mongo/client/mock_collection'
require 'mattermost/wekan/server'
require 'mattermost/wekan/config'
require 'mattermost/wekan/card_title'

module Mongo
  class Client
    def self.new(*)
      {
        cards: MockCollection.instance,
        activities: MockCollection.instance,
        card_comments: MockCollection.instance,
        boards: MockCollection.instance,
        swimlanes: MockCollection.instance,
        lists: MockCollection.instance
      }
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
