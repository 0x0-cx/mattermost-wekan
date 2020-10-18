# frozen_string_literal: true

require 'logger'
require 'sinatra'
require 'json'

require_relative '../../config'
require_relative 'message'
require_relative 'mongodb'

class Server < Sinatra::Base
  def initialize(app = nil, params = {})
    super(app)
    @config = params.fetch(:config, Config.new)
    @config.logger.debug 'start mattermost-wekan'
    @mongodb = Mongodb.new(@config)
    @mongodb.connect
  end

  set :bind, '0.0.0.0'

  post '/' do
    request_body = request.body.read.to_s
    if request_body.empty?
      body 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
      halt(400)
    end
    message = Message.new(JSON.parse(request_body), @config.mattermost_bot_token, @config.mattermost_url)
    if message.token == @config.mattermost_token
      if message.parent_wekan_link?
        @mongodb.insert_comment(message.card_id, message.board_id, message.text, message.user_id)
      else
        halt(200)
      end
    else
      @config.logger.warn 'wrong token. may be anyone try to hack bot'
      body 'token from request header not equal with configured mattermost outgoing webhook token'
      halt(400)
    end
  end
end
