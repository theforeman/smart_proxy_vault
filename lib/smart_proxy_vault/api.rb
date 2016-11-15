require_relative './authentication'
require_relative './helpers'

module VaultPlugin
  module API
    def self.included(klass)
      klass.send :include, Backend
      klass.extend Backend
    end

    module Backend
      include ::VaultPlugin::Authentication
      include ::VaultPlugin::Helpers

      class Client
        extend ::VaultPlugin::Helpers

        def self.issue_token(options)
          Vault.auth_token.create(options).auth.client_token
        end

        def self.issue_role_token(role, options)
          Vault.auth_token.create_with_role(role, options).auth.client_token
        end

        def self.lookup_self
          Vault.auth_token.lookup_self
        end

        def self.renew_self
          Vault.auth_token.renew_self(lookup_self.data[:creation_ttl])
        end
      end

      def metadata
        return {} unless add_token_metadata?
        { display_name: vault_client,
          meta: { client: vault_client, smartproxy_generated: true } }
      end

      def options(ttl)
        options = metadata.merge token_options
        options.merge(ttl: ttl) unless ttl.nil?
      end

      def issue(ttl, role)
        begin
          opts = options ttl
          role.nil? ? Client.issue_token(opts) : Client.issue_role_token(role, opts)
        rescue StandardError => e
          log_halt 500, 'Failed to generate Vault token ' + e.message
        end
      end

      def creation_ttl
        Client.lookup_self[:data][:creation_ttl]
      end

      def renew
        begin
          Client.renew_self
        rescue StandardError => e
          puts 'Failed to renew Vault token ' + e.message
        end
      end

      def start_renewal
        Thread.new do
          while true do
            renew
            sleep to_seconds(creation_ttl/3)
          end
        end
      end
    end
  end
end
