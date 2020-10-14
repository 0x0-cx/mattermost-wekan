class Config
  class << Config
    def mattermost_token
      ENV['MATTERMOST_TOKEN'] || raise('environment variable not set')
    end

    def mattermost_webhook_path
      ENV['MATTERMOST_WEBHOOK_PATH'] || raise('environment variable not set')
    end

    def mattermost_bot_token
      ENV['MATTERMOST_BOT_TOKEN'] || raise('environment variable not set')
    end

    def mattermost_url
      ENV['MATTERMOST_URL'] || raise('environment variable not set')
    end

    def wekan_db_url
      ENV['WEKAN_DB_URL'] || raise('environment variable not set')
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
