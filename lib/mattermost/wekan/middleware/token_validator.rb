# frozen_string_literal: true

require 'rack'

module Mattermost
  module Wekan
    module Middleware
      class TokenValidator
        attr_reader :app

        def initialize(app)
          @app = app
        end

        HELP_MESSAGE = 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
        WRONG_TOKEN_MESSAGE = 'token from request header not equal with configured token'

        def call(env)
          body = env[Rack::RACK_REQUEST_FORM_HASH]
          return response(HELP_MESSAGE) unless body

          app.config.logger.debug({ request_body: body }.inspect)
          return response(WRONG_TOKEN_MESSAGE) unless body['token'] == app.config.mattermost_token

          app.call(env)
        end

        def response(message)
          app.config.logger.debug({ response_code: 400, message: message }.inspect)
          Rack::Response.new(JSON({ message: message }),
                             400,
                             { 'content_type' => 'application/json' }).finish
        end
      end
    end
  end
end
