require 'bundler/setup'
Bundler.require

class Mongo::Client
  class MockCollection
    def find(*); [{ 'listId' => 1, 'swimlaneId' => 2 }]; end
    def insert_one(*); end
  end

  def self.new(*)
    {
      cards: MockCollection.new,
      activity: MockCollection.new,
      card_comments: MockCollection.new
    }
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

