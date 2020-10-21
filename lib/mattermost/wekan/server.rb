# frozen_string_literal: true

require 'logger'
require 'sinatra'
require 'json'

require 'mattermost/wekan/config'
require 'mattermost/wekan/message'
require 'mattermost/wekan/mongodb'
require 'mattermost/wekan/middleware/token_validator'
require 'mattermost/wekan/nickname'
require 'mattermost/wekan/card_title'
require 'mattermost/wekan/card'

module Mattermost
  module Wekan
    class Server < Sinatra::Base
      use Middleware::TokenValidator

      def initialize(app = nil, params = {})
        super(app)
        @config = params.fetch(:config, Config.new)
        @config.logger.info 'start mattermost-wekan'
        @nickname = Nickname.new(config: @config)
        @mongodb = Mongodb.new(config)
        @mongodb.connect
      end

      set :bind, '0.0.0.0'

      MONGO_ERROR = 'failed to insert comment to mongodb'
      SUCCESS_MESSAGE = 'successfully handle comment'
      NO_LINK = 'no link to wekan card found'

      post '/' do
        data = JSON.parse(request.body.read.to_s)
        message = Message.new(post_id: data['post_id'], config: config)
        config.logger.debug({ message: message }.inspect)
        make_response(code: 200, message: NO_LINK) unless message.should_send_to_wekan?

        insert_result = mongodb.inject_comment(card_id: message.card_id,
                                               board_id: message.board_id,
                                               comment_text: data['text'],
                                               user_id: config.user_map[data['user_id']])
        make_response(message: MONGO_ERROR, code: 500) unless insert_result

        make_response(message: SUCCESS_MESSAGE, code: 200)
      end

      command2column = {
        '/wi' => 'icebox',
        '/w-icebox' => 'icebox',
        '/wb' => 'backlog',
        '/w-backlog' => 'backlog'
      }

      post '/command' do
        card_title = CardTitle.new(text: @params['text'])
        card = Card.new(
          title: card_title.title,
          board_id: config.wekan_board_id,
          swimlane_id: mongodb.swimlane_id,
          description: card_title.description,
          user_id: config.user_map[@params['user_id']],
          assign_user_id: nickname.wekan_user_id(username: card_title.author),
          list_id: mongodb.list_id(title: command2column[@params['command']]),
          list_name: command2column[@params['command']]
        )
        make_response(message: MONGO_ERROR, code: 500) unless mongodb.inject_card(card)

        make_response(message: SUCCESS_MESSAGE, code: 200)
      end

      def make_response(code:, message:)
        config.logger.info({ code: code, message: message }.inspect)
        halt(code, { 'content_type' => 'application/json' }, JSON({ message: message }))
      end

      attr_reader :config, :mongodb, :nickname
    end
  end
end
