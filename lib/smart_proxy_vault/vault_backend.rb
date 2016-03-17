module VaultPlugin
  module VaultBackend
    class API
      attr_reader :connection

      def initialize(child)
        vault_settings = ::VaultPlugin::Plugin.settings.vault
        @connection = ::Vault::Client.new(vault_settings)
        @child = child
        @token_options = token_options
      end

      def issue_token
        @connection.auth_token.create(@token_options).auth.client_token
      end

      private
      def metadata
        if ::VaultPlugin::Plugin.settings.add_token_metadata == true
          return { meta: { client: @child, smartproxy_generated: true },
                   display_name: @child }
        end
        {}
      end

      def token_options
        metadata.merge ::VaultPlugin::Plugin.settings[:token_options]
      end
    end

    def issue
      begin
        vault = API.new vault_client
        vault.issue_token
      rescue StandardError => e
        log_halt 500, 'Failed to generate Vault token ' + e.message
      end
    end
  end
end
