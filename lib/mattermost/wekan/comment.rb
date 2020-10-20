# frozen_string_literal: true

require 'securerandom'
require 'attr_extras'

module Mattermost
  module Wekan
    class Comment
      vattr_initialize %i[user_id! card_id! board_id! text! list_id! swimlane_id!]

      def as_comment
        {
          _id: comment_id,
          text: text,
          boardId: board_id,
          cardId: card_id,
          createdAt: date_time,
          modifiedAt: date_time,
          userId: user_id
        }
      end

      def as_activity
        {
          userId: user_id,
          activityType: 'addComment',
          boardId: board_id,
          cardId: card_id,
          commentId: comment_id,
          listId: list_id,
          swimlaneId: swimlane_id,
          createdAt: date_time,
          modifiedAt: date_time
        }
      end

      def comment_id
        @comment_id ||= SecureRandom.uuid[0..16]
      end

      def date_time
        @date_time ||= DateTime.now.iso8601
      end

      attr_reader :text, :board_id, :card_id, :user_id, :list_id, :swimlane_id
    end
  end
end
