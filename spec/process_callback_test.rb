ENV['APP_ENV'] = 'test'

require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require_relative './../lib/callback_server'
require_relative './../lib/config'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    init_mock
    CallbackServer.new
  end

  it 'displays home page' do
    post '/'
  end

  def init_mock
    WebMock.disable_net_connect!(allow_localhost: false)
    WebMock.stub_request(:post, "#{Config.mattermost_url}/api/v4/users/login")
           .to_return(status: 200, body: { Token: 'sdf' }.to_json)
  end

end
