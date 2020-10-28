# frozen_string_literal: true

module Mattermost
  module Wekan
    class Label
      vattr_initialize %i[name!]

      COLORS = %w[
        green
        yellow
        orange
        red
        purple
        blue
        sky
        lime
        pink
        black
        silver
        peachpuff
        crimson
        plum
        darkgreen
        slateblue
        magenta
        gold
        navy
        gray
        saddlebrown
        paleturquoise
        mistyrose
        indigo
      ].freeze

      def random_color
        @random_color ||= COLORS.sample
      end

      def as_label
        {
          'color' => random_color,
          '_id' => new_id,
          'name' => name
        }
      end

      def new_id
        @new_id ||= SecureRandom.uuid[0..6]
      end
    end
  end
end
