require "uri"

class MessageParser
  class << MessageParser

    def find_card_id(message)
      url = extract_url message
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
      (URI.extract message).last
    end

  end
end
