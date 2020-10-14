require 'logger'
require 'sinatra'
require 'json'

require_relative 'config'
require_relative 'mattermost_api'
require_relative 'message_parser'
require_relative 'mongodb'

class CallbackServer < Sinatra::Base

  logger = Logger.new(STDOUT, Logger::DEBUG)

  logger.debug 'start mattermost-wekan'

  set :bind, '0.0.0.0'

  mongodb = Mongodb.new

  configure do
    mongodb.connect
  end

  post "/#{Config.mattermost_webhook_path}" do
    body = request.body.read.to_s
    if body.empty?
      body 'https://docs.mattermost.com/developer/webhooks-outgoing.html'
      halt 200
    end
    data = JSON.parse(body)
    if data['token'] == Config.mattermost_token
      if MattermostApi.parent? data['post_id']
        parent_post_text = MattermostApi.get_parent_post_text(data['post_id'])
        card_id = MessageParser.find_card_id parent_post_text
        halt 200 if card_id.nil?
        board_id = MessageParser.find_board_id parent_post_text
        mongodb.post_comment(card_id, board_id, data['text'], data['user_id'])
      end
    else
      logger.warn 'wrong token. may be anyone try to hack bot'
    end
  end

end


