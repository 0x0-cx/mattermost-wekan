# frozen_string_literal: true

require 'wannabe_bool'

module Mattermost
  module Wekan
    class Config
      def initialize(env = ENV)
        @env = env
      end

      def mattermost_token
        @env.fetch('MATTERMOST_TOKEN')
      end

      def mattermost_bot_token
        @env.fetch('MATTERMOST_BOT_TOKEN')
      end

      def mattermost_url
        @env.fetch('MATTERMOST_URL')
      end

      def wekan_db_url
        @env.fetch('WEKAN_DB_URL')
      end

      def wekan_url
        @env.fetch('WEKAN_URL')
      end

      def wekan_swimlane_name
        @env.fetch('WEKAN_SWIMLANE_NAME', 'Default')
      end

      def debug?
        @env['DEBUG']&.to_b
      end

      def user_map
        Hash[mattermost_user_list.zip(wekan_user_list)]
      end

      def channel2board
        Hash[mattermost_channel_list.zip(wekan_board_list)]
      end

      def logger
        Logger.new($stdout, level: (log_level || default_log_level))
      end

      private

      def default_log_level
        debug? ? Logger::DEBUG : Logger::INFO
      end

      def log_level
        @env['LOG_LEVEL']&.to_i
      end

      def mattermost_channel_list
        @env.fetch('MATTERMOST_CHANNEL_LIST').split(' ')
      end

      def wekan_board_list
        @env.fetch('WEKAN_BOARD_LIST').split(' ')
      end

      def wekan_user_list
        @env.fetch('WEKAN_USER_LIST').split(' ')
      end

      def mattermost_user_list
        @env.fetch('MATTERMOST_USER_LIST').split(' ')
      end
    end
  end
end
