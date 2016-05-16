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
        attr_reader :connection

        include ::VaultPlugin::Helpers

        def initialize
          @connection = ::Vault::Client.new(vault_settings)
        end

        def issue_token(options)
          @connection.auth_token.create(options).auth.client_token
        end

        def lookup_self
          @connection.auth_token.lookup_self
        end

        def renew_self
          @connection.auth_token.renew_self(lookup_self[:data][:creation_ttl])
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

      def vault
        Client.new
      end

      def issue(ttl)
        begin
          vault.issue_token options(ttl)
        rescue StandardError => e
          log_halt 500, 'Failed to generate Vault token ' + e.message
        end
      end

      def creation_ttl
        vault.lookup_self[:data][:creation_ttl]
      end

      def renew
        begin
          vault.renew_self
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
