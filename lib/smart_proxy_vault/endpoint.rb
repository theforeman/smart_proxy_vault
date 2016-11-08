require_relative './authentication'
require_relative './api'
require_relative './helpers'

module VaultPlugin
  class Endpoint < ::Sinatra::Base
    include ::Proxy::Log
    include ::VaultPlugin::Authentication
    include ::VaultPlugin::API
    helpers ::Proxy::Helpers, ::VaultPlugin::Helpers

    ::Sinatra::Base.register Authentication

    before do
      content_type :json
      authorized?
    end

    start_renewal

    get '/token/issue' do
      ttl = params[:ttl]
      role = params[:role]
      issue(ttl, role) if valid_ttl? ttl
    end
  end
end
