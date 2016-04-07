[![Build Status](https://img.shields.io/travis/visioncritical/smart_proxy_vault/master.svg)](https://travis-ci.org/visioncritical/smart_proxy_vault)
[![Code Quality](https://img.shields.io/codeclimate/github/visioncritical/smart_proxy_vault.svg)](https://codeclimate.com/github/visioncritical/smart_proxy_vault)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/visioncritical/smart_proxy_vault.svg)](https://codeclimate.com/github/visioncritical/smart_proxy_vault/coverage)
[![Gem](https://img.shields.io/gem/v/smart_proxy_vault.svg)](https://rubygems.org/gems/smart_proxy_vault/versions)
[![GitHub license](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE.md)


# Smart Proxy - Vault Plugin

A Smart Proxy plugin will return a Vault token after authenticating a client.

## Design

The authentication portion of this plugin has been designed to be modular. Below is a current list of clients this plugin knows how to authenticate:

* Chef

If you're unable to use one of the above to authenticate your clients, you can always write your own & submit a PR (see [DEVELOPMENT.md](documentation/DEVELOPMENT.md)).

## Installation

Add this line to your Smart Proxy bundler.d/vault.rb gemfile:

```ruby
gem 'smart_proxy_vault'
```

And then execute:

```bash
bundle install
```

## Settings

Example:

```yaml
---
:enabled: true
:auth_backend: 'chef'
:vault:
  :address: "https://vault.example.com"
  :token: "UUID"
  :ssl_verify: true
:add_token_metadata: true
:token_options:
  :policies: ['policyname']
  :ttl: '72h'
:chef:
  :endpoint: 'https://chef.example.com'
  :client: 'user'
  :key: '/path/to/client.pem'
  :ssl_verify: true
```

#### General

#####:enabled:

Toggles whether or not this plugin is enabled for Smart Proxy.

#####:auth_backend:

Specifies what authentication module you would like to use to authenticate your clients (must correspond to a filename in [lib/smart_proxy_vault/authentication/](lib/smart_proxy_vault/authentication/))

#####:vault:

A hash of Vault settings that are used to configure a connection to the Vault server (determined by the [Vault](https://github.com/hashicorp/vault-ruby) gem).

```yaml
# https://github.com/hashicorp/vault-ruby/blob/master/lib/vault/configurable.rb
:vault:
  :address:
  :token:
  :open_timeout:
  :proxy_address:
  :proxy_password:
  :proxy_port:
  :proxy_username:
  :read_timeout:
  :ssl_ciphers:
  :ssl_pem_file:
  :ssl_pem_passphrase:
  :ssl_ca_cert:
  :ssl_ca_path:
  :ssl_verify:
  :ssl_timeout:
  :timeout:
```

#####:add_token_metadata:

If set to true, this plugin will add the requesting client's ID (as determined by the auth_backend) in the metadata & display-name fields when requesting a token.

#####:token_options:

A hash of parameters that will be passed to the token creation call ([/auth/token/create](https://www.vaultproject.io/docs/auth/token.html)).

#### Chef Backend

Only to be specified when the `:auth_backend:` is `chef`. Refer to the [Chef backend](documentation/CHEF.md) documentation for more information.

#####:chef:

A hash of settings that are used to configure a connection to the Chef server (used by the [Chef API](https://github.com/sethvargo/chef-api) gem).

```yaml
# https://github.com/sethvargo/chef-api/blob/master/lib/chef-api/configurable.rb
:chef:
  :endpoint:
  :flavor:
  :client:
  :key:
  :proxy_address:
  :proxy_password:
  :proxy_port:
  :proxy_username:
  :ssl_pem_file:
  :ssl_verify:
  :user_agent:
```

## Usage

To configure this plugin you can use template from [settings.d/vault.yml.example](settings.d/vault.yml.example). You must place the vault.yml config file in your Smart Proxy's `config/settings.d/` directory.

### Endpoints

#### `/vault/token/issue`

##### Parameters

`ttl=X[d,h,m,s]`

Overrides the token TTL specified in the [`:token_options:`](#token_options) section. This value must be **lower** than the default TTL.

Example:

`/vault/token/issue?ttl=60s`

### Caveats

In order to use this plugin effectively, the Ruby installation on your Smart Proxy server should be version 2.0.0 or higher, and be compiled against a version of OpenSSL that supports TLS (=>1.0.1). I recommend using [RVM](https://rvm.io/) & [Passenger](https://www.phusionpassenger.com) to run your Smart Proxy server.

```
$ irb
2.2.1 :001 > require 'openssl'
 => true
2.2.1 :002 > OpenSSL::OPENSSL_VERSION
 => "OpenSSL 1.0.1e 11 Feb 2013"
 ```