require 'bundler/setup'
require 'process_callback_test'

class Mongo::Client
  def self.new(*)
    client = {
        cards: OpenStruct.new(find: [{ 'listId' => 1, 'swimlaneId' => 2 }]),
        activity: OpenStruct.new,
        card_comments: OpenStruct.new
    }
    client
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

