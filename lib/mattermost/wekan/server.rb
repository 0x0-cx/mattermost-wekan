# frozen_string_literal: true

require 'bundler'
Bundler.require(:default, (ENV['APP_ENV'] || 'development').to_sym)

require 'mattermost/wekan/config'
require 'mattermost/wekan/message'
require 'mattermost/wekan/mongodb'
require 'mattermost/wekan/middleware/token_validator'
require 'mattermost/wekan/nickname_store'
require 'mattermost/wekan/card_title'
require 'mattermost/wekan/card'
require 'mattermost/wekan/label'

module Mattermost
  module Wekan
    class Server < Sinatra::Base
      attr_reader :config, :mongodb, :nickname_store

      use Rack::JSONBodyParser
      use Middleware::TokenValidator

      def initialize(app = nil, params = {})
        super(app)

        @config = params.fetch(:config, Config.new)
        @config.logger.info 'start mattermost-wekan'
        @nickname_store = NicknameStore.new(config: @config)
        @mongodb = Mongodb.new(config)
        @mongodb.connect
      end

      set :bind, '0.0.0.0'

      MONGO_ERROR = 'failed to insert comment to mongodb'
      SUCCESS_MESSAGE = 'successfully handle comment'
      NO_LINK = 'no link to wekan card found'
      NO_TITLE = 'no title giving'

      post '/' do
        message = Message.new(post_id: @params['post_id'], config: config)
        config.logger.debug({ message: message }.inspect)
        make_response(code: 200, message: NO_LINK) unless message.should_send_to_wekan?

        insert_result = mongodb.inject_comment(card_id: message.card_id,
                                               board_id: message.board_id,
                                               comment_text: @params['text'],
                                               user_id: config.user_map[@params['user_id']])
        make_response(message: MONGO_ERROR, code: 500) unless insert_result

        make_response(message: SUCCESS_MESSAGE, code: 200)
      end

      COMMAND_2_COLUMN = {
        '/wi' => 'icebox',
        '/w-icebox' => 'icebox',
        '/wb' => 'backlog',
        '/w-backlog' => 'backlog'
      }.freeze

      post '/command' do
        card_title = CardTitle.new(text: @params['text'])
        card = Card.new(
          title: card_title.title,
          description: card_title.description,
          assignee_ids: card_title.assign_to.map { |username| nickname_store.wekan_user_id(username: username) },
          board_id: config.channel2board[@params['channel_id']],
          user_id: config.user_map[@params['user_id']],
          swimlane_name: config.wekan_swimlane_name,
          swimlane_id: mongodb.find_swimlane_by(board_id: config.channel2board[@params['channel_id']])['_id'],
          list_id: mongodb.find_list_by(title: COMMAND_2_COLUMN[@params['command']],
                                        board_id: config.channel2board[@params['channel_id']])['_id'],
          list_name: COMMAND_2_COLUMN[@params['command']],
          label_ids: card_title.tags.filter_map do |tag|
            mongodb.upsert_label(label: Label.new(name: tag),
                                 board_id: config.channel2board[@params['channel_id']])['_id']
          end
        )
        chat_answer(NO_TITLE) if card.title.empty?

        chat_answer(MONGO_ERROR) unless mongodb.inject_card(card)

        chat_answer(SUCCESS_MESSAGE)
      end

      def chat_answer(message)
        config.logger.info({ chat_answer: message }.inspect)
        halt(200, nil, message)
      end

      def make_response(code:, message:)
        config.logger.info({ code: code, message: message }.inspect)
        halt(code, { 'content_type' => 'application/json' }, JSON({ message: message }))
      end
    end
  end
end
