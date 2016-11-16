module RequestHelpers
  extend RR::DSL
  extend self

  # Need to stub this before we require smart_proxy_vault/endpoint
  def configure_settings
    stub.proxy(::VaultPlugin::Plugin.settings).token_options {{
      ttl: '12h'
    }}
    stub.proxy(::VaultPlugin::Plugin.settings).vault {{
      address: 'https://vault.example.com',
      token: 'GUID',
      ssl_verify: true
    }}
  end

  RequestHelpers.configure_settings
end
