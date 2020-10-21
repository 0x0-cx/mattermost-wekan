# frozen_string_literal: true

require 'rack'

module Mattermost
  module Wekan
    module Middleware
      class TokenValidator
        def initialize(app)
          @app = app
        end

        HELP_MESSAGE = 'Server work but you must configure mattermost outgoing hooks to this server.
             more info https://docs.mattermost.com/developer/webhooks-outgoing.html'
        WRONG_TOKEN_MESSAGE = 'token from request header not equal with configured token'

        def call(env)
          input = env['rack.input'].read
          env['rack.input'].rewind
          return response(HELP_MESSAGE) if input.empty?

          app.config.logger.debug({ request_body: input }.inspect)
          return response(WRONG_TOKEN_MESSAGE) unless token_match?(env, input)

          app.call(env)
        end

        def response(message)
          app.config.logger.debug({ response_code: 400, message: message }.inspect)
          Rack::Response.new(JSON({ message: message }),
                             400,
                             { 'content_type' => 'application/json' }).finish
        end

        def token_match?(env, input)
          request_token(env, input) == path2token[env['PATH_INFO']]
        end

        def request_token(env, input)
          case env['PATH_INFO']
          when '/'
            JSON.parse(input)['token']
          when '/command'
            extract_token(input)
          end
        end

        def path2token
          {
            '/' => app.config.mattermost_token,
            '/command' => app.config.mattermost_slash_token
          }
        end

        def extract_token(string)
          arr = URI.decode_www_form(string)
          res = arr.find do |element|
            element[0] == 'token'
          end
          res[1]
        end

        attr_reader :app
      end
    end
  end
end
