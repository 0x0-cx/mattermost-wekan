# frozen_string_literal: true

require 'uri'

class Message
  class << Message
    def find_card_id(message)
      url = extract_url message
      return nil if url.nil?

      extract_card_id url
    end

    def find_board_id(message)
      url = extract_url message
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
end
