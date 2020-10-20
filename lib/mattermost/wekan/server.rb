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
        @mongodb = Mongodb.new(config)
        @mongodb.connect
      end

      set :bind, '0.0.0.0'

      HELP_MESSAGE = 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
      WRONG_TOKEN_MESSAGE =  'token from request header not equal with configured mattermost outgoing webhook token'

      post '/' do
        request_body = request.body.read.to_s
        bad_request(HELP_MESSAGE) if request_body.empty?

        data = JSON.parse(request_body)
        message = Message.new(post_id: data['post_id'], config: config)

        bad_request unless data['token'] == config.mattermost_token

        unless message.should_send_to_wekan?
          halt(200, { 'content_type' => 'application/json' }, JSON({ is_error: false, message: '' }))
        end

        mongodb.insert_comment(card_id: message.card_id,
                               board_id: message.board_id,
                               comment_text: data['text'],
                               user_id: config.user_map[data['user_id']])
        halt(200,
             { 'content_type' => 'application/json' },
             JSON({ is_error: false, message: 'successfully handle comment' }))
      end

      def bad_request(message)
        halt(400, { 'content_type' => 'application/json' }, JSON({ is_error: true, message: message }))
      end

      attr_reader :config, :mongodb
    end
  end
end
