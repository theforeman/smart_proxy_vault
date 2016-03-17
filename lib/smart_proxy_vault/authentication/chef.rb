require 'chef-api'

module VaultPlugin
  module Authentication
    module Chef
      def vault_client
        request.env['HTTP_X_VAULT_CLIENT']
      end

      def signature
        request.env['HTTP_X_VAULT_SIGNATURE'] || request.env['HTTP_X_VAULT_SIGNATURE'].chomp
      end

      def authorized?
        logger.info('Starting Chef client authentication for smart_proxy_vault')
        request.env.each do |key,value|
          logger.debug("header #{key}: #{value}")
        end if logger.level == 0

        if vault_client.nil? || signature.nil?
          log_halt 401, "Failed to authenticate Chef client - #{vault_client}. Missing headers."
        end

        unless authenticate signature
          log_halt 401, "Failed to authenticate Chef client - #{vault_client}"
        end
        logger.info("Successfully authenticated Chef client - #{vault_client}")
      end

      def chefapi
        chefapi_settings = ::VaultPlugin::Plugin.settings.chef
        connection = ::ChefAPI::Connection.new(chefapi_settings)
        connection.ssl_verify = ssl_verify
        connection
      end

      def authenticate(signature)
        begin
          node = chefapi.clients.fetch vault_client
        rescue StandardError => e
          log_halt 401, 'Failed to authenticate to the Chef server: ' + e.message
        end
        log_halt(401, "Could not find Chef client - #{vault_client}") if node.nil?

        rsa = OpenSSL::PKey::RSA.new node.public_key
        decoded_signature = Base64.decode64(signature)
        # The body should contain the public key of the node
        body = Digest::MD5.hexdigest rsa.public_key.to_s

        rsa.verify(OpenSSL::Digest::SHA512.new, decoded_signature, body)
      end
    end
  end
end
