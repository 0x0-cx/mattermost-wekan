# frozen_string_literal: true

require 'mongo'
require 'date'
require 'securerandom'

require_relative '../../config'

class Mongodb
  def connect
    @client = Mongo::Client.new([Config.wekan_db_url], database: 'wekan', direct_connection: true)
  end

  def insert_comment(card_id, board_id, comment, mattermost_user_id)
    comment_id = SecureRandom.uuid[0..16]
    insert_card_comments(comment_id, comment, board_id, card_id, mattermost_user_id)
    insert_activity(card_id, board_id, mattermost_user_id, comment_id)
  end

  private

  def insert_card_comments(comment_id, comment, board_id, card_id, mattermost_user_id)
    comment = {
      _id: comment_id,
      text: comment,
      boardId: board_id,
      cardId: card_id,
      createdAt: DateTime.now.iso8601,
      modifiedAt: DateTime.now.iso8601,
      userId: Config.user_map[mattermost_user_id]
    }
    @client[:card_comments].insert_one comment
  end

  def insert_activity(card_id, board_id, mattermost_user_id, comment_id)
    card = @client[:cards].find(_id: card_id).first
    activity = {
      userId: Config.user_map[mattermost_user_id],
      activityType: 'addComment',
      boardId: board_id,
      cardId: card_id,
      commentId: comment_id,
      listId: card['listId'],
      swimlaneId: card['swimlaneId'],
      createdAt: DateTime.now.iso8601,
      modifiedAt: DateTime.now.iso8601
    }
    @client[:activity].insert_one(activity)
  end
end
