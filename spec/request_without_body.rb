require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require_relative './../lib/callback_server'
require_relative './../lib/config'

RSpec.describe 'Sinatra app' do
  include Rack::Test::Methods

  def app
    CallbackServer.new
  end

  before :each do
    Mongo::Client.new[:cards].reset!
  end

  it 'without body' do
    post "/#{Config.mattermost_webhook_path}"
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
