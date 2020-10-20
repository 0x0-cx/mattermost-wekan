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
    WebMock.disable_net_connect!(allow_localhost: false)
    TestUtils.instance.mock_mattermost_post_endpoint('2', parent_id: '-2')
    TestUtils.instance.mock_mattermost_post_endpoint('-2', message: 'Просто какой то текст')
    Mongo::Client.new[:cards].reset!
  end

  it 'comment on simple post' do
    post('/', TestUtils.instance.callback_body('2'), content_type: 'application/json')
    client = Mongo::Client.new
    expect(client[:cards].written?).to eq(false)
  end
end
