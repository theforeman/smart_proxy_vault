require_relative './test_helper'
require 'smart_proxy_vault'
require_relative './helpers/helpers'
require 'smart_proxy_vault/endpoint'

class RequestTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include RequestHelpers
  include VaultPlugin::API

  ###
  # Helper Methods
  ###

  def stub_authorized?(bool)
    any_instance_of(VaultPlugin::Endpoint) do |klass|
      stub(klass).authorized? { true }
    end
  end

  def stub_client
    any_instance_of(VaultPlugin::Endpoint) do |klass|
      stub(klass).client { 'fry' }
    end
  end

  def stub_add_token_metadata
    any_instance_of(VaultPlugin::Endpoint) do |klass|
      stub(klass).add_token_metadata? { false }
    end
  end

  def token
    {lease_id: "",
     renewable: false,
     lease_duration: 43200,
     data: nil,
     warnings: nil,
     auth: { client_token: "GUID", lease_duration: 43200, renewable: true }}
  end

  def token_lookup
    {request_id: "GUID",
     lease_id: "",
     renewable: false,
     lease_duration: 0,
     data:
      {accessor: "GUID",
       creation_time: 1111111111,
       creation_ttl: 43200,
       display_name: "token",
       explicit_max_ttl: 0,
       id: "GUID",
       last_renewal_time: 1111111111,
       meta: nil,
       num_uses: 0,
       orphan: false,
       path: "auth/token/create/foorole",
       policies: ["default"],
       renewable: true,
       role: "foorole",
       ttl: 84971},
     wrap_info: nil,
     warnings: nil,
     auth: nil}
  end

  def token_renew
    {client_token: "GUID",
     accessor: "GUID",
     policies: ["default"],
     metadata: nil,
     lease_duration: 43200,
     renewable: true}
  end

  def stub_response
    stub_request(:post, "https://vault.example.com/v1/auth/token/create").
      with(:body => "{\"ttl\":\"12h\"}",
           :headers => { 'Accept'=>['*/*', 'application/json'],
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Content-Type'=>'application/json',
                         'User-Agent'=>['Ruby', 'VaultRuby/0.7.3 (+github.com/hashicorp/vault-ruby)'],
                         'X-Vault-Token'=>'GUID'}).
      to_return(:status => 200, :body => token.to_json, :headers => { 'Content-Type'=>'application/json' })
  end

  def stub_response_role
    stub_request(:post, "https://vault.example.com/v1/auth/token/create/foo").
      with(:headers => { 'Accept'=>['*/*', 'application/json'],
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Content-Type'=>'application/json',
                         'User-Agent'=>['Ruby', 'VaultRuby/0.7.3 (+github.com/hashicorp/vault-ruby)'],
                         'X-Vault-Token'=>'GUID'}).
      to_return(:status => 200, :body => token.to_json, :headers => { 'Content-Type'=>'application/json' })
  end

  def stub_response_lookup
    stub_request(:get, "https://vault.example.com/v1/auth/token/lookup-self").
      with(:headers => { 'Accept'=>['*/*', 'application/json'],
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Content-Type'=>'application/json',
                         'User-Agent'=>['Ruby',
                          'VaultRuby/0.7.3 (+github.com/hashicorp/vault-ruby)'],
                          'X-Vault-Token'=>'GUID'}).
      to_return(:status => 200, :body => token_lookup.to_json, :headers => { 'Content-Type'=>'application/json' })
  end

  def stub_response_renew
    stub_request(:put, "https://vault.example.com/v1/auth/token/renew-self").
      with(:body => "{\"increment\":43200}",
           :headers => { 'Accept'=>['*/*', 'application/json'],
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Content-Type'=>'application/json',
                         'User-Agent'=>['Ruby',
                         'VaultRuby/0.7.3 (+github.com/hashicorp/vault-ruby)'],
                         'X-Vault-Token'=>'GUID'}).
      to_return(:status => 200, :body => token_renew.to_json, :headers => { 'Content-Type'=>'application/json' })
  end

  ###
  # Test Methods
  ###

  def app
    VaultPlugin::Endpoint.new
  end

  def setup
    stub_authorized?(true)
    stub_client
    configure_settings
  end

  def test_vault_token_issue
    stub_response
    get '/token/issue', ttl: '12h'
    assert last_response.ok?
  end

  def test_vault_token_issue_role
    stub_add_token_metadata
    stub_response_role
    get '/token/issue', role: 'foo'
    assert last_response.ok?
  end

  def test_bad_ttl_override
    get '/token/issue', ttl: '24h'
    assert last_response.bad_request?
  end

  def test_token_renewal
    stub_response_lookup
    stub_response_renew
    renew
  end

  def test_vault_settings
    failure_msg = 'Unexpected Vault Configuration'
    assert_equal [], vault_settings.values - Vault.options.values.compact, failure_msg
  end
end
