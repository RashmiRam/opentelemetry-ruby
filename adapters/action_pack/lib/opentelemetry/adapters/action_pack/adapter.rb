# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry/adapters/rack/middlewares/tracer_middleware'
# require_relative 'middlewares'

module OpenTelemetry
  module Adapters
    module ActionPack
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
          patch_action_controller
        end

        present do
          defined?(::ActionPack)
        end

        private

        def require_dependencies
          require_relative 'patches/action_controller'
        end

        def patch_action_controller
          ::ActionController::Metal.prepend(Patches::ActionController::Metal)
        end
      end
    end
  end
end
