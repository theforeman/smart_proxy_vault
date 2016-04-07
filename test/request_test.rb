require 'test_helper'
require 'smart_proxy_vault'

class RequestTest < Test::Unit::TestCase
  include Rack::Test::Methods

  ###
  # Helper Methods
  ###

  def stub_authorized?(bool)
    any_instance_of(VaultPlugin::VaultAPI) do |klass|
      stub(klass).authorized? { true }
    end
  end

  def stub_client
    any_instance_of(VaultPlugin::VaultAPI) do |klass|
      stub(klass).client { 'fry' }
    end
  end

  def token
    {:lease_id => "",
     :renewable => false,
     :lease_duration => 43200,
     :data => nil,
     :warnings => nil,
     :auth => { :client_token => "GUID", :lease_duration => 43200, :renewable => true }}
  end

  def stub_response
    stub_request(:post, "https://vault.example.com/v1/auth/token/create").
    with(:body => "{\"ttl\":\"12h\"}",
         :headers => { 'Accept'=>['*/*', 'application/json'], 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Content-Type'=>'application/json', 'User-Agent'=>['Ruby', 'VaultRuby/0.3.0 (+github.com/hashicorp/vault-ruby)'],
                       'X-Vault-Token'=>'GUID' }).
    to_return(:status => 200, :body => token.to_json, :headers => { 'Content-Type'=>'application/json' })
  end

  ###
  # Test Methods
  ###

  def app
    VaultPlugin::VaultAPI.new
  end

  def setup
    stub_authorized?(true)
    stub_client
    stub.proxy(::VaultPlugin::Plugin.settings).token_options {{
      ttl: '12h'
    }}
    stub.proxy(::VaultPlugin::Plugin.settings).vault {{
      address: 'https://vault.example.com',
      token: 'GUID',
      ssl_verify: true
    }}
  end

  def test_vault_token_issue
    stub_response
    get '/token/issue', ttl: '12h'
    assert last_response.ok?
  end

  def test_bad_ttl_override
    get '/token/issue', ttl: '24h'
    assert last_response.bad_request?
  end
end
