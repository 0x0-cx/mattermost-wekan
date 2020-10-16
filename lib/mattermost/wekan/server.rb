# frozen_string_literal: true

require 'logger'
require 'sinatra'
require 'json'

require_relative '../../config'
require_relative 'message'
require_relative 'mongodb'

class Server < Sinatra::Base
  logger = Logger.new($stdout, Logger::DEBUG)

  logger.debug 'start mattermost-wekan'

  set :bind, '0.0.0.0'

  mongodb = Mongodb.new
  config = Config.new

  configure do
    mongodb.connect
  end

  post '/' do
    request_body = request.body.read.to_s
    if request_body.empty?
      body 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
      halt(400)
    end
    message = Message.new(request_body)
    if message.token == config.mattermost_token
      if message.parent_wekan_link?
        mongodb.insert_comment(message.card_id, message.board_id, message.text, message.user_id)
      else
        halt(200)
      end
    else
      logger.warn 'wrong token. may be anyone try to hack bot'
      body 'token from request header not equal with configured mattermost outgoing webhook token'
      halt(400)
    end
  end
end
