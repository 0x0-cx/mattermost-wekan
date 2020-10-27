# frozen_string_literal: true

require 'attr_extras'
require 'faraday'
require 'concurrent'

module Mattermost
  module Wekan
    class NicknameStore
      vattr_initialize [:config!, :cache] do
        @cache ||= Concurrent::Hash.new
      end

      def wekan_user_id(username:)
        config.user_map[mattermost_user_id(username)]
      end

      private

      def mattermost_user_id(username)
        cache[username] ||= fetch_user_id(username)
      end

      def fetch_user_id(username)
        user_data = fetch_user_data(username)
        return unless user_data

        user_data['id']
      end

      def fetch_user_data(username)
        resp = Faraday.get("#{config.mattermost_url}/api/v4/users/username/#{username}",
                           nil,
                           { 'Authorization' => "Bearer #{config.mattermost_bot_token}" })
        config.logger.debug({ resp: resp }.inspect)
        return unless resp.success?

        JSON.parse(resp.body)
      end
    end
  end
end
