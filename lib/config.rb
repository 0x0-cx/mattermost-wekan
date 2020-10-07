class Config
  class << Config

    def mattermost_token
      ENV['MATTERMOST_TOKEN']
    end

    def mattermost_webhook_path
      ENV['MATTERMOST_WEBHOOK_PATH']
    end

    def mattermost_bot_username
      ENV['MATTERMOST_BOT_USERNAME']
    end

    def mattermost_bot_password
      ENV['MATTERMOST_BOT_PASSWORD']
    end

    def mattermost_url
      ENV['MATTERMOST_URL']
    end

    def wekan_db_url
      ENV['WEKAN_DB_URL']
    end

    def user_map
      Hash[mattermost_user_list.zip(wekan_user_list)]
    end

    private

    def wekan_user_list
      ENV['WEKAN_USER_LIST'].split ' '
    end

    def mattermost_user_list
      ENV['MATTERMOST_USER_LIST'].split ' '
    end

  end
end
