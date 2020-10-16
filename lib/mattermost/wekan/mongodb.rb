# frozen_string_literal: true

require 'mongo'
require 'date'

require_relative '../../config'

class Mongodb
  def connect
    @config = Config.new
    @client = Mongo::Client.new("mongodb://#{@config.wekan_db_url}/wekan")
  end

  def insert_comment(card_id, board_id, comment_text, mattermost_user_id)
    comment = Comment.new(@config.user_map[mattermost_user_id], card_id, board_id)
    @client[:card_comments].insert_one(comment.as_comment(comment_text))

    card = @client[:cards].find(_id: card_id).first
    @client[:activity].insert_one(comment.as_activity(card['listId'], card['swimlaneId']))
  end
end
