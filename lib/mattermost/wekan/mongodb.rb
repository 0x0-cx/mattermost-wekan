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

      def inject_comment(card_id:, board_id:, comment_text:, user_id:)
        card =  client[:cards].find({ '_id' => card_id }).first
        comment = Comment.new(user_id: user_id,
                              card_id: card_id,
                              board_id: board_id,
                              text: comment_text,
                              list_id: card['listId'],
                              swimlane_id: card['swimlaneId'])
        comment_result = insert_card_comment(comment: comment)
        activity_result = insert_activity(activity: comment.as_activity)
        comment_result && activity_result
      end

      def inject_card(card)
        insert_card(card: card) && insert_activity(activity: card.as_activity)
      end

      def find_swimlane_by(title: config.wekan_swimlane_name)
        client[:swimlanes].find({ 'boardId' => config.wekan_board_id, 'title' => title }).first || default_swimlane
      end

      def find_list_by(title:)
        client[:lists].find({ 'boardId' => config.wekan_board_id, 'title' => title }).first || default_list
      end

      private

      def default_swimlane
        client[:swimlanes].find({ 'boardId' => config.wekan_board_id, 'archived' => false })
                          .min_by { |element| element['title'] }
      end

      def default_list
        client[:lists].find({ 'boardId' => config.wekan_board_id, 'archived' => false })
                      .min_by { |element| element['title'] }
      end

      def insert_card(card:)
        config.logger.debug({ card: card }.inspect)
        client[:cards].insert_one(card.as_card).successful?
      end

      def insert_card_comment(comment:)
        config.logger.debug({ comment: comment.as_comment }.inspect)
        client[:card_comments].insert_one(comment.as_comment).successful?
      end

      def insert_activity(activity:)
        config.logger.debug({ activity: activity }.inspect)
        client[:activities].insert_one(activity).successful?
      end

      def client
        @client ||= Mongo::Client.new(@config.wekan_db_url)
      end
    end
  end
end
