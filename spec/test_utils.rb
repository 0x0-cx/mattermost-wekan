# frozen_string_literal: true

require 'webmock'
require 'singleton'
class TestUtils
  include WebMock::API
  include Singleton

  WebMock.enable!

  def initialize
    @config = config
  end

  def callback_body(post_id)
    {
      token: @config.mattermost_token,
      post_id: post_id,
      text: 'text text',
      user_id: '1'
    }.to_json
  end

  def mock_mattermost_post_endpoint(post_id, body)
    WebMock.stub_request(:get, "#{@config.mattermost_url}/api/v4/posts/#{post_id}")
           .to_return(status: 200, body: body.to_json, headers: {
                        content_type: 'application/json'
                      })
  end

  def config
    Mattermost::Wekan::Config.new(test_enviroment)
  end

  private

  def test_enviroment
    {
      'MATTERMOST_TOKEN' => 'token',
      'MATTERMOST_BOT_TOKEN' => 'token',
      'MATTERMOST_URL' => 'https://mattermost.org',
      'WEKAN_DB_URL' => 'wekan.org',
      'WEKAN_URL' => 'https://wekan.org',
      'WEKAN_USER_LIST' => '1',
      'MATTERMOST_USER_LIST' => '1',
      'DEBUG' => 'true'
    }
  end
end
