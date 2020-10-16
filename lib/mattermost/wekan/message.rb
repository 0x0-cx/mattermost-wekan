# frozen_string_literal: true

require 'uri'

class Message
  def initialize(data)
    parent_message = get_parent_post_text(data['post_id'])
    @text = data['text']
    @user_id = data['user_id']
    @board_id = find_board_id(parent_message)
    @card_id = find_card_id(parent_message)
  end

  attr_reader :board_id, :card_id, :text, :user_id

  def has_parent_wekan_link?
    !(@card_id.nil? && @board_id.nil?)
  end

  private

  def get_parent_post_text(post_id)
    body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{post_id}", Config.mattermost_bot_token)
    parent_post_id = JSON.parse(body.body)['parent_id']
    body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{parent_post_id}", Config.mattermost_bot_token)
    JSON.parse(body.body)['message']
  end

  def find_card_id(message)
    url = extract_url message
    return nil if url.nil?

    extract_card_id url
  end

  def find_board_id(message)
    url = extract_url message
    return nil if url.nil?

    extract_board_id url
  end

  def extract_card_id(url)
    id = extract_ids(url)[2]
    id.tr(')', '')
  end

  def extract_board_id(url)
    extract_ids(url)[1]
  end

  def extract_ids(url)
    data = url.split('/')
    arr = []
    arr[1] = data[data.size - 3]
    arr[2] = data.last
    arr
  end

  def extract_url(message)
    urls = (URI.extract message)
    urls.last if urls.length == 1 && urls.last.include?('wekan')
  end
end
