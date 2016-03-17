require 'test_helper'
require 'webmock/test_unit'
require 'mocha/test_unit'
require 'rack/test'

# require 'smart_proxy_vault/example'
# require 'smart_proxy_vault/example_api'

class ExampleApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    VaultPlugin::Api.new
  end

  def test_returns_hello_greeting
    # add test here
  end

end
