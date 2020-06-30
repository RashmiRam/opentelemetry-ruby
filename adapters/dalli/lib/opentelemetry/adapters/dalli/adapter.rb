# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Adapters
    module Dalli
      # class Railtie < Rails::Railtie
      #   initializer 'opentelemetry.before_initialize' do |app|
      #     app.middleware.insert_before(0, OpenTelemetry::Adapters::Rack::Middlewares::TracerMiddleware)

      #   end
      # end
      # The Adapter class contains logic to detect and install the Rails
      # instrumentation adapter
      class Adapter < OpenTelemetry::Instrumentation::Adapter
        install do |_config|
          require_dependencies
          patch_dalli
        end

        present do
          defined?(::Dalli)
        end

        private

        def require_dependencies
          require_relative 'patches/server'
        end

        def patch_dalli
          ::Dalli::Server.send(:include, Patches::Server)
        end
      end
    end
  end
end
