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
        @client = Mongo::Client.new(@config.wekan_db_url)
        @config.logger.info("connect to mongodb #{@config.wekan_db_url}") if @config.debug?
      end

      def insert_comment(card_id:, board_id:, comment_text:, user_id:)
        @config.logger.info("insert comment #{comment_text}") if @config.debug?
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
        client[:card_comments].insert_one(comment.as_comment).successful?
      end

      def insert_activity(comment:)
        client[:activity].insert_one(comment.as_activity).successful?
      end

      attr_reader :client, :config
    end
  end
end
