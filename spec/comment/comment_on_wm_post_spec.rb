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
    WebMock.disable_net_connect!(allow_localhost: false)
    TestUtils.instance.mock_mattermost_post_endpoint('1', parent_id: '-1')
    TestUtils.instance.mock_mattermost_post_endpoint('-1', message:
        'Какой то текст [https://wekan.org/12/sdf/13](sdf) ещ')
    Mongo::Client.new[:cards].reset!
  end

  it 'comment on wekan-mattermost post' do
    post('/', TestUtils.instance.callback_body(1), { 'CONTENT_TYPE' => 'application/json' })
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].correct?).to eq(true)
    expect(client[:cards].written?).to eq(true)
  end
end
