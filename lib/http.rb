require 'net/http'

class Http
  class << Http

    def post(url, body)
      url = URI.parse(url)
      header = {
        'Content-Type': 'text/json'
      }
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      # TODO: какие то локальные траблы с reverse proxy иначе не работает
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url.request_uri, header)
      request.body = body
      http.request(request)
    end

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
