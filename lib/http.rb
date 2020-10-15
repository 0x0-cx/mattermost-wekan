# frozen_string_literal: true

require 'net/http'
require 'uri'

class Http
  class << Http
    def get(url, token)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{token}"
      http.request(request)
    end
  end
end
