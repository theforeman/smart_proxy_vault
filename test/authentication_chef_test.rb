require_relative './test_helper'
require 'smart_proxy_vault/authentication/chef'

class AuthenticationChefTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Proxy::Pluggable

  ###
  # Classes
  ###

  class Mock
    include VaultPlugin::Authentication::Chef

    def logger
      @logger ||= Logger.new(StringIO.new)
      @logger.level = Logger::INFO
      @logger
    end

    def log_halt(*args)
      throw :halt
    end
  end

  ###
  # Helper Methods
  ###

  def sign_request(key_path)
    rsa = OpenSSL::PKey::RSA.new File.read key_path
    body = Digest::MD5.hexdigest rsa.public_key.to_s
    Base64.strict_encode64(rsa.sign(OpenSSL::Digest::SHA512.new, body))
  end

  def stub_client(client, signature)
    stub.proxy(AuthenticationChefTest::Mock).new do |obj|
      stub(obj).vault_client { client }
      stub(obj).signature { signature }
    end
  end

  def stub_response(client, public_key, status=200)
    response = %({"name": "#{client}", "admin": false, "public_key": "#{public_key.gsub("\n","\\n")}", "private_key": false, "validator": false})
    stub_request(:get, "https://chef.example.com/clients/#{client}").to_return(:status => status, :body => response.to_s, :headers => {'content-type' => 'application/json'} )
  end

  ###
  # Test Methods
  ###

  def setup
    stub.proxy(::VaultPlugin::Plugin.settings).chef {{
      :endpoint => 'https://chef.example.com',
      :client => 'fry',
      :key => 'test/fixtures/authentication/chef/fry.pem',
      :ssl_verify => true
    }}

    @fry_client = FactoryGirl.create(:rsa, file: 'test/fixtures/authentication/chef/fry.pem' )
    @fry_client_path = 'test/fixtures/authentication/chef/fry.pem'
    @bender_client = FactoryGirl.create(:rsa, file: 'test/fixtures/authentication/chef/bender.pem' )
    @bender_client_path = 'test/fixtures/authentication/chef/bender.pem'

    @fry_signature = sign_request @fry_client_path
    @bender_signature = sign_request @bender_client_path
  end

  def test_signature_verification_match
    stub_client 'fry', @fry_signature
    stub_response 'fry', @fry_client.public_key.to_s
    chefauth = Mock.new
    assert_nothing_thrown do
      assert chefauth.authorized?, 'Encoding & Decoding a message with the same key should pass verification'
    end
  end

  def test_signature_verification_mismatch
    stub_client 'bender', @bender_signature
    stub_response 'bender', @fry_client.public_key.to_s
    chefauth = Mock.new
    assert_throws :halt do
      refute chefauth.authorized?, 'Encoding & Decoding a message with the different key should fail verification'
    end
  end

  def test_header_requirement
    stub_client(nil, nil)
    chefauth = Mock.new
    assert_throws :halt do
      refute chefauth.authorized?, 'A request without headers should fail'
    end
  end

  def test_client_not_found
    stub_client('zoidberg', @bender_signature)
    stub_response('zoidberg', @bender_signature, 404)
    chefauth = Mock.new
    assert_throws :halt do
      refute chefauth.authorized?, %(It should fail when a client can't be found on the Chef server)
    end
  end
end
