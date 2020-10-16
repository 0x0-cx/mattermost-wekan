# frozen_string_literal: true

require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require_relative './../lib/mattermost/wekan/server'
require_relative './../lib/config'

RSpec.describe 'Sinatra app' do
  include Rack::Test::Methods

  def app
    Server.new(nil, { config: Config.new(TestUtils.instance.test_enviroment) })
  end

  before :each do
    Mongo::Client.new[:cards].reset!
  end

  it 'without body' do
    post '/'
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
