# frozen_string_literal: true

require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require 'mattermost/wekan/server'
require 'mattermost/wekan/config'
require_relative 'test_utils'

RSpec.describe 'Sinatra app' do
  include Rack::Test::Methods

  def app
    Mattermost::Wekan::Server.new(nil, { config: TestUtils.instance.config })
  end

  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
    TestUtils.instance.mock_mattermost_post_endpoint('5', parent_id: '-5')
    TestUtils.instance.mock_mattermost_post_endpoint('-5', message:
        'Какой то текст [https://vk.com/12/sdf/13](sdf) https://youtube.com/12/sdf/13 ещ')

    Mongo::Client.new[:cards].reset!
  end

  it 'comment on post with two url' do
    post('/', TestUtils.instance.callback_body('5'), content_type: 'application/json')
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
