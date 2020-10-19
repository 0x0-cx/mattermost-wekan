# frozen_string_literal: true

require 'logger'
require 'sinatra'
require 'json'

require 'mattermost/wekan/config'
require 'mattermost/wekan/message'
require 'mattermost/wekan/mongodb'

module Mattermost
  module Wekan
    class Server < Sinatra::Base
      def initialize(app = nil, params = {})
        super(app)
        @config = params.fetch(:config, Config.new)
        @config.logger.debug 'start mattermost-wekan'
        @mongodb = Mongodb.new(@config)
        @mongodb.connect
      end

      set :bind, '0.0.0.0'

      HELP_MESSAGE = 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
      WRONG_TOKEN_MESSAGE =  'token from request header not equal with configured mattermost outgoing webhook token'
      WRONG_TOKEN_MESSAGE_LOG = 'wrong token. may be anyone try to hack bot'

      post '/' do
        request_body = request.body.read.to_s
        bad_request(HELP_MESSAGE) if request_body.empty?

        data = JSON.parse(request_body)
        message = Message.new(text: data['text'],
                              user_id: @config.user_map[data['user_id']],
                              post_id: data['post_id'],
                              config: @config)
        unless data['token'] == @config.mattermost_token
          bad_request(WRONG_TOKEN_MESSAGE)
          @config.logger.warn(WRONG_TOKEN_MESSAGE_LOG)
        end

        if message.parent_wekan_link?
          @mongodb.insert_comment(message.card_id, message.board_id, message.text, message.user_id)
        else
          halt(200)
        end
      end

      def bad_request(message)
        body(message)
        halt(400)
      end
    end
  end
end
