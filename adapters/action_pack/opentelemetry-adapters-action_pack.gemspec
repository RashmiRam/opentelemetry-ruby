# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opentelemetry/adapters/action_pack/version'

Gem::Specification.new do |spec|
  spec.name        = 'opentelemetry-adapters-action_pack'
  spec.version     = OpenTelemetry::Adapters::ActionPack::VERSION
  spec.authors     = ['Rashmi R']
  spec.email       = ['rashmi.ramanathan@freshworks.com']

  spec.summary     = 'ActionPack instrumentation adapter for the OpenTelemetry framework'
  spec.description = 'ActionPack instrumentation adapter for the OpenTelemetry framework'
  spec.homepage    = 'https://github.com/open-telemetry/opentelemetry-ruby'
  spec.license     = 'Apache-2.0'

  spec.files = ::Dir.glob('lib/**/*.rb') +
               ::Dir.glob('*.md') +
               ['LICENSE']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'opentelemetry-api', '~> 0.4.0'
  spec.add_dependency 'opentelemetry-adapters-rack', '~> 0.4.0'

  spec.add_development_dependency 'appraisal', '~> 2.2.0'
  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'opentelemetry-sdk', '~> 0.0'
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'rails', '~> 5.0.0'
  spec.add_development_dependency 'rubocop', '~> 0.73.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'sprockets', '< 4'
  spec.add_development_dependency 'sqlite3', '~> 1.4.1'
  spec.add_development_dependency 'webmock', '~> 3.7.6'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-doctest', '~> 0.1.6'
end
