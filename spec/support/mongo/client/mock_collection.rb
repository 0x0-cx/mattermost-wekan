# frozen_string_literal: true

require 'singleton'

module Mongo
  class Client
    class MockCollection
      include Singleton

      def initialize
        @correct = true
        @written = false
      end

      def find(*)
        [{ 'listId' => 1, 'swimlaneId' => 2 }]
      end

      def insert_one(element)
        @written = true
        @correct = if !element[:text].nil?
                     comment_correct?(element)
                   else
                     activity_correct?(element)
                   end
      end

      def correct?
        @correct
      end

      def written?
        @written
      end

      def reset!
        @correct = true
        @written = false
      end

      private

      def comment_correct?(element)
        element[:boardId].eql?('12') &&
          element[:cardId].eql?('13') &&
          element[:userId].eql?('1')  &&
          element[:text].eql?('text text')
      end

      def activity_correct?(element)
        element[:userId].eql?('1') &&
          element[:activityType].eql?('addComment') &&
          element[:boardId].eql?('12') &&
          element[:cardId].eql?('13') &&
          element[:listId].eql?(1) &&
          element[:swimlaneId].eql?(2)
      end
    end
  end
end
