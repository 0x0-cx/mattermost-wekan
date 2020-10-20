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
        make_response(message: HELP_MESSAGE, code: 400) if request_body.empty?

        data = JSON.parse(request_body)
        config.logger.info("receive #{request_body}") if config.debug?
        make_response(message: WRONG_TOKEN_MESSAGE, code: 400) unless data['token'] == config.mattermost_token

        message = Message.new(post_id: data['post_id'], config: config)
        make_response(code: 200) unless message.should_send_to_wekan?

        insert_result = mongodb.insert_comment(card_id: message.card_id,
                                               board_id: message.board_id,
                                               comment_text: data['text'],
                                               user_id: config.user_map[data['user_id']])
        make_response(message: 'failed to insert comment to mongodb', code: 500) unless insert_result

        make_response(message: 'successfully handle comment', code: 200)
      end

      def make_response(code:, message: '')
        config.logger.info("response code = #{code} message = #{message}") if config.debug?
        halt(code, { 'content_type' => 'application/json' }, JSON({ message: message }))
      end

      attr_reader :config, :mongodb
    end
  end
end
