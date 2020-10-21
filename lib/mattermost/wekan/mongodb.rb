# frozen_string_literal: true

require 'mongo'
require 'date'

require 'mattermost/wekan/config'
require 'mattermost/wekan/comment'

module Mattermost
  module Wekan
    class Mongodb
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def connect
        client
        config.logger.debug("connect to mongodb #{config.wekan_db_url}")
      end

      def insert_comment(card_id:, board_id:, comment_text:, user_id:)
        config.logger.debug("insert comment #{comment_text}")
        card =  client[:cards].find({ '_id' => card_id }).first
        comment = Comment.new(user_id: user_id,
                              card_id: card_id,
                              board_id: board_id,
                              text: comment_text,
                              list_id: card['listId'],
                              swimlane_id: card['swimlaneId'])
        comment_result = insert_card_comment(comment: comment)
        activity_result = insert_activity(comment: comment)
        comment_result && activity_result
      end

      private

      def insert_card_comment(comment:)
        config.logger.debug({ comment_as_comment: comment.as_comment }.inspect)
        client[:card_comments].insert_one(comment.as_comment).successful?
      end

      def insert_activity(comment:)
        config.logger.debug({ comment_as_activity: comment.as_activity }.inspect)
        client[:activities].insert_one(comment.as_activity).successful?
      end

      def client
        @client ||= Mongo::Client.new(@config.wekan_db_url)
      end
    end
  end
end
