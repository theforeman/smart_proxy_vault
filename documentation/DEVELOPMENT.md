# Development

## Versioning
This module uses [Semantic Versioning](http://semver.org/).

## Branching
Please adhere to the branching guidelines set out by Vincent Driessen in this [post](http://nvie.com/posts/a-successful-git-branching-model/).

## Authentication Methods

Any new authentication backend will need to placed in `lib/smart_proxy_vault/authentication/`. The name of the file will be the name of the backend in `vault.yml`. Your backend will need to be nested underneath `::VaultPlugin::Authentication`, and it must define at least two methods (i.e. `authorized?`, & `vault_client`). Please also submit a markdown document explaining how your backend authenticates its clients.

```
module VaultPlugin
  module Authentication
    # Must match the name of the file
    module BackendName
      def vault_client
      end

      def authorized?
      end
    end
  end
end
```