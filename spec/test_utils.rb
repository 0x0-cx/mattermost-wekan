class TestUtils
  class << TestUtils
    def callback_body(post_id)
      {
        token: Config.mattermost_token,
        post_id: post_id,
        text: 'text text',
        user_id: '1'
      }.to_json
    end

    def mock_mattermost_post_endpoint(post_id, body)
      WebMock.stub_request(:get, "#{Config.mattermost_url}/api/v4/posts/#{post_id}")
             .to_return(status: 200, body: body.to_json, headers: {
                          content_type: 'application/json'
                        })
    end
  end
end
