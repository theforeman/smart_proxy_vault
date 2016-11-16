module VaultPlugin
  module Helpers
    def vault_settings
      ::VaultPlugin::Plugin.settings.vault
    end

    def settings_ttl
      ::VaultPlugin::Plugin.settings.token_options[:ttl]
    end

    def token_options
      ::VaultPlugin::Plugin.settings.token_options
    end

    def add_token_metadata?
      ::VaultPlugin::Plugin.settings.add_token_metadata
    end

    def vault_client_configure
      Vault.configure do |config|
        vault_settings.each do |k, v|
          config.send("#{k}=", v)
        end
      end
    end

    def to_seconds(string)
      case string.slice(-1)
      when 'd'
        string.tr('d', '').to_i * 24 * 3600
      when 'h'
        string.tr('h', '').to_i * 3600
      when 'm'
        string.tr('m', '').to_i * 60
      when 's'
        string.tr('s', '').to_i
      else
        log_halt 400, "Invalid TTL - #{string}. Must end with 'd', 'h', 'm' or 's'."
      end
    end

    # Only allow clients to specify a TTL that is shorter than the default
    def valid_ttl?(ttl)
      return true if ttl.nil? || settings_ttl.nil?
      unless (to_seconds(settings_ttl) >= to_seconds(ttl))
        log_halt 400, "Invalid TTL - #{ttl}. Must be shorter or equal to #{settings_ttl}."
      end
      true
    end
  end
end
