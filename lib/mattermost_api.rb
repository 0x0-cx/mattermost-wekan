require 'logger'

require_relative 'http'

class MattermostApi
  class << MattermostApi

    def get_parent_post_text(post_id)
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{post_id}", Config.mattermost_bot_token)
      parent_post_id = JSON.parse(body.body)['parent_id']
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{parent_post_id}", Config.mattermost_bot_token)
      JSON.parse(body.body)['message']
    end

    def parent?(post_id)
      body = Http.get("#{Config.mattermost_url}/api/v4/posts/#{post_id}", Config.mattermost_bot_token)
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
