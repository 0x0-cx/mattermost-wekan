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
        return if wekan_url.nil?

        arr = wekan_url.split('/')
        arr[arr.size - 3]
      end

      def card_id
        id = wekan_url&.split('/')&.last
        return if id.nil?

        id.tr(')', '')
      end

      private

      def post
        @post ||= fetch_post(post_id)
      end

      def parent_post
        @parent_post ||= begin
          fetch_post(post['parent_id']) unless post.nil?
        end
      end

      def parent_post_message
        return if parent_post.nil?

        parent_post['message']
      end

      def wekan_url
        return if parent_post_message.nil?

        urls = URI.extract(parent_post_message)
        urls.last if urls.length == 1 && urls.last.include?(config.wekan_url)
      end

      def fetch_post(post_id)
        return if post_id.nil?

        body = Faraday.get("#{config.mattermost_url}/api/v4/posts/#{post_id}",
                           nil,
                           { 'Authorization' => "Bearer #{config.mattermost_bot_token}" }).body
        JSON.parse(body)
      end

      attr_reader :post_id, :config
    end
  end
end
