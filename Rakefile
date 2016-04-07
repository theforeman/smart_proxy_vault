require 'rake'
require 'rake/testtask'
require "bundler/gem_tasks"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test Vault plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << %w(. lib test)
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
