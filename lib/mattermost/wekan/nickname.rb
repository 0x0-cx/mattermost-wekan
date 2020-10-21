# frozen_string_literal: true

require 'attr_extras'
require 'faraday'
require 'concurrent'

module Mattermost
  module Wekan
    class Nickname
      attr_reader :cache, :config

      def initialize(config:)
        @config = config
        @cache = Concurrent::Hash.new
      end

      def wekan_user_id(username:)
        id = user_id(username)
        return unless id

        config.user_map[id]
      end

      private

      def user_id(username)
        return cache[username] if cache.include?(username)

        user_id = fetch_user_id(username)
        return unless user_id

        cache[username] = user_id
      end

      def fetch_user_id(username)
        resp = Faraday.get("#{config.mattermost_url}/api/v4/users/username/#{username}",
                           nil,
                           { 'Authorization' => "Bearer #{config.mattermost_bot_token}" })
        config.logger.debug({ resp: resp }.inspect)
        return unless resp.success?

        JSON.parse(resp.body)['id']
      end
    end
  end
end
