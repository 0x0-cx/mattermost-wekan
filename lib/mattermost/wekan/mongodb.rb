# frozen_string_literal: true

require 'mongo'
require 'date'

require 'mattermost/wekan/config'
require 'mattermost/wekan/comment'

module Mattermost
  module Wekan
    class Mongodb
      def initialize(config)
        @config = config
      end

      def connect
        @client = Mongo::Client.new("mongodb://#{@config.wekan_db_url}/wekan")
      end

      def insert_comment(card_id, board_id, comment_text, mattermost_user_id)
        card = @client[:cards].find(_id: card_id).first
        comment = Comment.new(user_id: @config.user_map[mattermost_user_id],
                              card_id: card_id,
                              board_id: board_id,
                              text: comment_text,
                              last_id: card['listId'],
                              swimlane_id: card['swimlaneId'])
        @client[:card_comments].insert_one(comment.as_comment)
        @client[:activity].insert_one(comment.as_activity)
      end
    end
  end
end
