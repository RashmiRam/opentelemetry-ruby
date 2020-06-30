# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry/adapters/active_record/events'
# require_relative 'middlewares'

module OpenTelemetry
  module Adapters
    module ActiveRecord
      # class Railtie < Rails::Railtie
      #   initializer 'opentelemetry.before_initialize' do |app|
      #     app.middleware.insert_before(0, OpenTelemetry::Adapters::Rack::Middlewares::TracerMiddleware)

      #   end
      # end
      # The Adapter class contains logic to detect and install the Rails
      # instrumentation adapter
      class Adapter < OpenTelemetry::Instrumentation::Adapter
        install do |_config|
          patch_active_record
        end

        present do
          defined?(::ActiveRecord)
        end

        private

        def patch_active_record
          Events.subscribe!
        end
      end
    end
  end
end
