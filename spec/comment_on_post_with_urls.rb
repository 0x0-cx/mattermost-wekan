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
    WebMock.disable_net_connect!(allow_localhost: false)
    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/4")
           .to_return(status: 200, body: { parent_id: '-4' }.to_json, headers: {
                        content_type: 'application/json'
                      })
    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/-4")
           .to_return(status: 200, body: {
             message: 'Какой то текст [https://vk.com/12/sdf/13](sdf) ещ'
           }.to_json,
                      headers: {
                        content_type: 'application/json'
                      })

    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/5")
           .to_return(status: 200, body: { parent_id: '-5' }.to_json, headers: {
                        content_type: 'application/json'
                      })
    WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/-5")
           .to_return(status: 200, body: {
             message: 'Какой то текст [https://vk.com/12/sdf/13](sdf) https://youtube.com/12/sdf/13 ещ'
           }.to_json,
                      headers: {
                        content_type: 'application/json'
                      })

    Mongo::Client.new[:cards].reset!
  end

  it 'comment on post with non wekan url' do
    post "/#{Config.mattermost_webhook_path}",
         {
           token: Config.mattermost_token,
           post_id: '4',
           text: 'text text',
           user_id: '1'
         }.to_json,
         content_type: 'application/json'
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].correct?).to eq(true)
    expect(client[:cards].written?).to eq(false)
  end

  it 'comment on post with two or more url' do
    post "/#{Config.mattermost_webhook_path}",
         {
           token: Config.mattermost_token,
           post_id: '5',
           text: 'text text',
           user_id: '1'
         }.to_json,
         content_type: 'application/json'
    expect(last_response).to be_ok
    client = Mongo::Client.new
    expect(client[:cards].correct?).to eq(true)
    expect(client[:cards].written?).to eq(false)
  end
end
