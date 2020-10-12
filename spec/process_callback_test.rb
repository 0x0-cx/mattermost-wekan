ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'

require_relative './../lib/callback_server'

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    get '/'
  end
end
