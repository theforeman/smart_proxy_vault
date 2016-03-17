module VaultPlugin
  class VaultAPI < ::Sinatra::Base
    include ::Proxy::Log
    include ::VaultPlugin::Authentication
    include ::VaultPlugin::VaultBackend
    helpers ::Proxy::Helpers

    ::Sinatra::Base.register Authentication

    before do
      content_type :json
      authorized?
    end

    get '/token/issue' do
      issue
    end
  end
end
