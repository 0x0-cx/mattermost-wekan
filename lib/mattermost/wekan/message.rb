# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'attr_extras'

module Mattermost
  module Wekan
    class Message
      vattr_initialize %i[post_id! config!]

      def should_send_to_wekan?
        card_id && board_id
      end

      def board_id
        return unless wekan_url

        wekan_url.split('/').at(-3)
      end

      def card_id
        return unless (id = wekan_url&.split('/')&.last)

        id.tr(')', '')
      end

      private

      def post
        @post ||= fetch_post(post_id)
      end

      def parent_post
        return unless post

        @parent_post ||= fetch_post(post['parent_id'])
      end

      def parent_post_message
        return unless parent_post

        parent_post['message']
      end

      def wekan_url
        return unless parent_post_message

        urls = URI.extract(parent_post_message)
        urls.last if urls.length == 1 && urls.last.include?(config.wekan_url)
      end

      def fetch_post(post_id)
        return unless post_id

        body = Faraday.get("#{config.mattermost_url}/api/v4/posts/#{post_id}",
                           nil,
                           { 'Authorization' => "Bearer #{config.mattermost_bot_token}" }).body
        JSON.parse(body)
      end
    end
  end
end