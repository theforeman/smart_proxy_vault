require_relative 'authentication/chef'

module VaultPlugin
  module Authentication
    def auth_backend
      ::VaultPlugin::Plugin.settings.auth_backend.to_sym
    end

    def auth_module
      Object.const_get('::VaultPlugin::Authentication::' + auth_backend.capitalize.to_s)
    end

    # Creates convenient accessor methods for all keys underneath auth_backend
    def create_setting_accessors
      ::VaultPlugin::Plugin.settings[auth_backend].each do |key,value|
        define_singleton_method(key.to_sym) { value }
      end
    end

    def authorized?
      create_setting_accessors
      extend auth_module
      authorized?
    end

    # Returns the human-readable identity for the requesting client
    # Optionally used in a token's metadata & display-name
    def vault_client
      extend auth_module
      vault_client
    end
  end
end
