# frozen_string_literal: true

require 'uri'
require 'faraday'

module Mattermost
  module Wekan
    class Message
      def initialize(text:, user_id:, post_id:, config:)
        @text = text
        @user_id = user_id
        @post_id = post_id
        @config = config
      end

      attr_reader :text, :user_id, :post_id

      def parent_wekan_link?
        !(card_id.nil? && board_id.nil?)
      end

      def board_id
        @board_id ||= begin
          unless url.nil?
            arr = url.split('/')
            arr[arr.size - 3]
          end
        end
      end

      def card_id
        @card_id ||= begin
          url&.split('/')&.last
        end
      end

      private

      def post
        @post ||= get(@post_id)
      end

      def parent_post_message
        parent_post_id = post['parent_id']
        return unless parent_post_id

        @parent_post = get(parent_post_id)['message']
      end

      def url
        @url ||= begin
          unless parent_post_message.nil?
            urls = URI.extract(parent_post_message)
            urls.last if urls.length == 1 && urls.last.include?('wekan')
          end
        end
      end

      def get(post_id)
        body = Faraday.get("#{@config.mattermost_url}/api/v4/posts/#{post_id}",
                           nil,
                           { 'Authorization' => "Bearer #{@config.mattermost_bot_token}" }).body
        JSON.parse(body)
      end
    end
  end
end
