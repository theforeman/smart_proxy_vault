# Authentication Backend - Chef

This backend verifies Chef clients by expecting clients to hit the endpoint with two HTTP headers defined:

## X_VAULT_CLIENT

This header should contain the Chef client ID (e.g. `knife client [name]`). This is used by the [Chef API](https://github.com/sethvargo/chef-api) gem to fetch a client.

## X_VAULT_SIGNATURE

This header should be a Base64 encoded signature with the body containing the client's public key. An example of how to generate on your client nodes:

```ruby
require 'openssl'
require 'base64'

def sign_request(key_path)
  rsa = OpenSSL::PKey::RSA.new File.read key_path
  body = Digest::MD5.hexdigest rsa.public_key.to_s
  Base64.strict_encode64(rsa.sign(OpenSSL::Digest::SHA512.new, body))
end

signature = sign_request('/etc/chef/client.pem')
```