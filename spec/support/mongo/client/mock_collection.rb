# frozen_string_literal: true

require 'singleton'

module Mongo
  class Client
    class MockCollection
      include Singleton

      def initialize
        @correct = true
        @written = false
        @updated = false
      end

      def find(*)
        [{ 'listId' => 1,
           'swimlaneId' => 2,
           '_id' => 'sdf',
           'title' => 'title',
           'labels' => [{ '_id' => 'saved', 'name' => 'saved' }, { '_id' => 'ed', 'name' => 'second_name' }] }]
      end

      def insert_one(element)
        @written = true
        check_correctness(element)
        MockCollection.instance
      end

      def update_one(_filter, update)
        @updated = true
        label = update['$addToSet'][:labels]
        @correct = label[:name].eql?('backlog')
      end

      def successful?
        true
      end

      def correct?
        @correct
      end

      def written?
        @written
      end

      def updated?
        @updated
      end

      def reset!
        @correct = true
        @written = false
        @updated = false
      end

      private

      def check_correctness(element)
        @correct = case element.count
                   when 7
                     comment_correct?(element)
                   when 9
                     activity_comment_correct?(element)
                   when 15
                     card_correct?(element)
                   when 12
                     activity_card_correct?(element)
                   end
      end

      def comment_correct?(element)
        element[:boardId].eql?('12') &&
          element[:cardId].eql?('13') &&
          element[:userId].eql?('1')  &&
          element[:text].eql?('text text')
      end

      def activity_comment_correct?(element)
        element[:userId].eql?('1') &&
          element[:activityType].eql?('addComment') &&
          element[:boardId].eql?('12') &&
          element[:cardId].eql?('13') &&
          element[:swimlaneId].eql?(2)
      end

      def card_correct?(element)
        element[:title].eql?('title исправить оптимизацию в проекте') &&
          element[:boardId].eql?('12') &&
          element[:type].eql?('cardType-card') &&
          element[:description].eql?('description  text') &&
          element[:userId].eql?('1') &&
          (!element[:labelIds].empty? || element[:labels] == %w[saved new-label])
      end

      def activity_card_correct?(element)
        element[:userId].eql?('1') &&
          element[:activityType].eql?('createCard') &&
          element[:boardId].eql?('12') &&
          element[:swimlaneId].eql?('sdf') &&
          element[:listId].eql?('sdf') &&
          element[:cardTitle].eql?('title исправить оптимизацию в проекте')
      end
    end
  end
end
