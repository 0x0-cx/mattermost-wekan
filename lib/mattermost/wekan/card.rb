# frozen_string_literal: true

module Mattermost
  module Wekan
    class Card
      vattr_initialize %i[title! board_id! swimlane_id! description! user_id! assignee_ids! list_id! list_name!
                          swimlane_name! label_ids!]

      # https://github.com/wekan/wekan/blob/master/models/cards.js
      def as_card
        {
          _id: card_id,
          title: title,
          boardId: board_id,
          swimlaneId: swimlane_id,
          sort: 0,
          type: 'cardType-card',
          archived: false,
          createdAt: date_time,
          modifiedAt: date_time,
          dateLastActivity: date_time,
          description: description,
          assignees: assignee_ids,
          userId: user_id,
          labelIds: label_ids,
          listId: list_id
        }
      end

      def as_activity
        {
          _id: activity_id,
          userId: user_id,
          activityType: 'createCard',
          boardId: board_id,
          createdAt: date_time,
          modifiedAt: date_time,
          swimlaneId: swimlane_id,
          listId: list_id,
          cardId: card_id,
          cardTitle: title,
          listName: list_name,
          swimlaneName: swimlane_name
        }
      end

      def activity_id
        @activity_id ||= SecureRandom.uuid[0..16]
      end

      def card_id
        @card_id ||= SecureRandom.uuid[0..16]
      end

      def date_time
        @date_time ||= DateTime.now
      end
    end
  end
end
