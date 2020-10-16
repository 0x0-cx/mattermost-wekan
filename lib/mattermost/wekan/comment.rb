require 'securerandom'

class Comment
  def initialize(user_id, card_id, board_id)
    @user_id = user_id
    @card_id = card_id
    @board_id = board_id

    @comment_id ||= SecureRandom.uuid[0..16]
    @date_time ||= DateTime.now.iso8601
  end

  def as_comment(comment)
    {
      _id: @comment_id,
      text: comment,
      boardId: @board_id,
      cardId: @card_id,
      createdAt: @date_time,
      modifiedAt: @date_time,
      userId: @user_id
    }
  end

  def as_activity(list_id, swimlane_id)
    {
      userId: @user_id,
      activityType: 'addComment',
      boardId: @board_id,
      cardId: @card_id,
      commentId: comment_id,
      listId: list_id,
      swimlaneId: swimlane_id,
      createdAt: @date_time,
      modifiedAt: @date_time
    }
  end
end
