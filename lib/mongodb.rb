require 'mongo'
require 'date'
require 'securerandom'

require './../lib/config'

class Mongodb

  @client

  def connect
    @client = Mongo::Client.new([Config.wekan_db_url], database: 'wekan', direct_connection: true)
  end

  def post_comment(card_id, board_id, comment, mattermost_user_id)
    comment_id = SecureRandom.uuid[0..16]
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
