require 'logger'

require_relative 'http'

class MattermostApi
  class << MattermostApi

    @token = nil

    def authorize
      body = {
        login_id: Config.mattermost_bot_username,
        password: Config.mattermost_bot_password
      }
      response = Http.post("#{Config.mattermost_url}/#{mattermost_api_path}/users/login",  body.to_json)
      @token = response['Token'] || raise('could not get token')
      logger.debug 'successfully retrieve token'
    end

    def get_parent_post_text(post_id)
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{post_id}", @token)
      parent_post_id = JSON.parse(body.body)['parent_id']
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{parent_post_id}", @token)
      JSON.parse(body.body)['message']
    end

    def parent?(post_id)
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{post_id}", @token)
      parent_post_id = JSON.parse(body.body)['parent_id']
      !parent_post_id.empty?
    end

    def mattermost_api_path
      'api/v4'
    end

    def logger
      Logger.new(STDOUT, Logger::DEBUG)
    end

  end
end
