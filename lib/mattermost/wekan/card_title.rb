# frozen_string_literal: true

require 'attr_extras'

module Mattermost
  module Wekan
    class CardTitle
      vattr_initialize %i[text!]

      def title
        title_words.select do |word|
          !nickname?(word) && !tag?(word)
        end.join(' ')
      end

      def description
        text.split("\n\n", 2).last.strip
      end

      def tag
        title_words.filter_map do |word|
          word.tr('#', '') if tag?(word)
        end
      end

      def assign_to
        title_words.filter_map { |word| word.tr('@', '') if nickname?(word) }.take(1)
      end

      private

      def tag?(word)
        word.start_with?('#')
      end

      def nickname?(word)
        word.start_with?('@')
      end

      def title_words
        text.split("\n\n").at(0).split
      end
    end
  end
end
