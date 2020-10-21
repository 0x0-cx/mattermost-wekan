# frozen_string_literal: true

require 'attr_extras'

module Mattermost
  module Wekan
    class CardTitle
      vattr_initialize %i[text!]

      def title
        words = title_words.select do |word|
          !username?(word) && !tag?(word)
        end
        words.join(' ')
      end

      def description
        text.split("\n\n").at(1).strip
      end

      def tag
        tags = title_words.select do |word|
          tag?(word)
        end
        tags.map! do |word|
          word.tr('#', '')
        end
      end

      def author
        title_words.select do |word|
          username?(word)
        end.first.tr('@', '')
      end

      private

      def tag?(word)
        word.start_with?('#')
      end

      def username?(word)
        word.start_with?('@')
      end

      def title_words
        text.split("\n\n").at(0).split
      end
    end
  end
end
