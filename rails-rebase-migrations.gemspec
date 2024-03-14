# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'rails-rebase-migrations'
  spec.version = '1.2.0'
  spec.licenses = ['MIT']
  spec.summary = 'Rebase Rails migrations to be the latest'
  spec.authors = ['Pioneer Valley Books']
  spec.description = File.read('README.md')

  spec.files = Dir['lib/**/*.rb']
  spec.executables = ['rebase-migrations']

  spec.homepage = 'https://github.com/Pioneer-Valley-Books/rebase-migrations'
  spec.metadata = { 'rubygems_mfa_required' => 'true' }
  spec.required_ruby_version = '>=3.2'

  spec.add_runtime_dependency 'rails', '>= 6.1', '< 8'
end
