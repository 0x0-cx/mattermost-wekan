require 'webmock/rspec'
require 'rack/test'

require_relative 'spec_helper'
require_relative './../lib/callback_server'
require_relative './../lib/config'

RSpec.describe 'S inatra app' do
  include Rack::Test::Methods


  def app
    CallbackServer.new
  end

  before :each do
    WebMock.disable_net_connect!(allow_localhost: false)
    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/1")
           .to_return(status: 200, body: { parent_id: '-1' }.to_json, headers: {
                        content_type: 'application/json'
                      })
    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/-1")
           .to_return(status: 200, body: {
             message: 'Какой то текст [https://wekan.org/12/sdf/13](sdf) ещ'
           }.to_json,
                      headers: {
                        content_type: 'application/json'
                      })

  end

  it 'displays home page' do
    post "/#{Config.mattermost_webhook_path}",
         {
           token: Config.mattermost_token,
           post_id: '1'
         }.to_json,
         content_type: 'application/json'

  end

end
