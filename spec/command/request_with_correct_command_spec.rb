# frozen_string_literal: true

require 'rack/test'

require_relative './../spec_helper'
require_relative './../test_utils'

RSpec.describe 'commands webhook' do
  include Rack::Test::Methods

  def app
    Mattermost::Wekan::Server.new(nil, { config: TestUtils.instance.config })
  end

  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: false)
    WebMock.stub_request(:get, "#{TestUtils.instance.config.mattermost_url}/api/v4/users/username/alex")
           .to_return(status: 200, body: { id: '1' }.to_json, headers: {
                        content_type: 'application/json'
                      })
  end

  it 'request with correct command' do
    message = "title @alex  исправить   #backlog     оптимизацию @afgan0r в проекте #bug

    description  text "
    post('/command',
         { user_id: '1', text: message, token: TestUtils.instance.config.mattermost_token, command: '/wi' }.to_json,
         { 'CONTENT_TYPE' => 'application/json' })
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].correct?).to eq(true)
    expect(client[:cards].written?).to eq(true)
  end
end
