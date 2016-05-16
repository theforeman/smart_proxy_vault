require 'smart_proxy_vault/endpoint'

map '/vault' do
  run VaultPlugin::Endpoint
end
