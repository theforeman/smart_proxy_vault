module VaultPlugin
  class VaultAPI < ::Sinatra::Base
    include ::Proxy::Log
    include ::VaultPlugin::Authentication
    include ::VaultPlugin::VaultBackend
    helpers ::Proxy::Helpers, ::VaultPlugin::Helpers

    ::Sinatra::Base.register Authentication

    before do
      content_type :json
      authorized?
    end

    get '/token/issue' do
      ttl = params[:ttl]
      issue(ttl) if valid_ttl? ttl
    end
  end
end
