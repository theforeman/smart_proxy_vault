require File.expand_path('../lib/smart_proxy_vault/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_vault'
  s.version = VaultPlugin::VERSION

  s.summary = 'Authenticates a client & returns a Vault token'
  s.description = 'Authenticates a client & returns a Vault token'
  s.authors = %w{Riley Shott}
  s.email = 'riley.shott@visioncritical.com'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = Dir['{lib,settings.d,bundler.d,test}/**/*'] + s.extra_rdoc_files
  s.test_files = s.files.grep(%r{^(test)/})
  s.homepage = 'http://github.com/visioncritical/smart_proxy_vault'
  s.license = 'GPLv3'

  s.add_development_dependency('bundler', '~> 1.11')
  s.add_development_dependency('rake', '~> 10')
  s.add_development_dependency('pry', '~> 0.10')
  s.add_development_dependency('test-unit', '~> 2')
  s.add_development_dependency('mocha', '~> 1')
  s.add_development_dependency('webmock', '~> 1')
  s.add_development_dependency('rack-test', '~> 0')
  s.add_development_dependency('factory_girl', '~> 4.0')
  s.add_development_dependency('rr', '~> 1.1')

  s.add_runtime_dependency('chef-api', '~> 0.5.0')
  s.add_runtime_dependency('vault', '~> 0.3.0')
end
