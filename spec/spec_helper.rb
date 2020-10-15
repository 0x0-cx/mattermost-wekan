require 'bundler/setup'
Bundler.require

class Mongo::Client
  class MockCollection
    # rubocop:disable Style/ClassVars
    @@correct = true
    @@written = false

    def find(*)
      [{ 'listId' => 1, 'swimlaneId' => 2 }]
    end

    def insert_one(element)
      @@written = true
      unless element[:text].nil?
        if !element[:boardId].eql?('12') ||
           !element[:cardId].eql?('13') ||
           !element[:userId].eql?('1')  ||
           !element[:text].eql?('text text')
          @@correct = false
        end
      end
      unless element[:activityType].nil?
        if !element[:userId].eql?('1') ||
           !element[:activityType].eql?('addComment') ||
           !element[:boardId].eql?('12') ||
           !element[:cardId].eql?('13') ||
           !element[:listId].eql?(1) ||
           !element[:swimlaneId].eql?(2)
          @@correct = false
        end
      end
    end

    def correct?
      @@correct
    end

    def written?
      @@written
    end

    def reset!
      @@correct = true
      @@written = false
    end
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
