# frozen_string_literal: true

require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require_relative './../lib/callback_server'
require_relative './../lib/config'
require_relative 'test_utils'

RSpec.describe 'Sinatra app' do
  include Rack::Test::Methods

  def app
    CallbackServer.new
  end

  before :each do
    WebMock.disable_net_connect!(allow_localhost: false)
    TestUtils.mock_mattermost_post_endpoint '2', parent_id: '-2'
    TestUtils.mock_mattermost_post_endpoint '-2', message: 'Просто какой то текст'
    Mongo::Client.new[:cards].reset!
  end

  it 'comment on simple post' do
    post "/#{Config.mattermost_webhook_path}",
         TestUtils.callback_body('2'),
         content_type: 'application/json'
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
