# frozen_string_literal: true

require 'webmock/rspec'
require 'rack/test'

require_relative '../spec_helper'
require_relative '../test_utils'

RSpec.describe 'Sinatra app' do
  include Rack::Test::Methods

  def app
    Mattermost::Wekan::Server.new(nil, { config: TestUtils.instance.config })
  end

  before :each do
    Mongo::Client.new[:cards].reset!
  end

  it 'without body' do
    post '/'
    expect(last_response.status).to eq(400)
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
