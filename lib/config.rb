# frozen_string_literal: true

class Config
  def initialize(env = ENV)
    @env = env
  end

  def mattermost_token
    @env.fetch('MATTERMOST_TOKEN')
  end

  def mattermost_bot_token
    @env.fetch('MATTERMOST_BOT_TOKEN')
  end

  def mattermost_url
    @env.fetch('MATTERMOST_URL')
  end

  def wekan_db_url
    @env.fetch('WEKAN_DB_URL')
  end

  def user_map
    Hash[mattermost_user_list.zip(wekan_user_list)]
  end

  def logger
    Logger.new($stdout, Logger::DEBUG)
  end

  private

  def wekan_user_list
    @env.fetch('WEKAN_USER_LIST').split(' ')
  end

  def mattermost_user_list
    @env.fetch('MATTERMOST_USER_LIST').split(' ')
  end
end
