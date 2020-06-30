# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry/adapters/dalli/utils'

module OpenTelemetry
  module Adapters
    module Dalli
      module Patches
        # Module to prepend to Dalli::server for instrumentation
        module Server
          def self.included(base)
            base.send(:prepend, InstanceMethods)
          end

        # InstanceMethods - implementing instrumentation
          module InstanceMethods
            def request(op, *args)

              tracer.in_span(
                 OpenTelemetry::Adapters::Dalli::Utils.span_name(op),
                attributes: client_attributes(options).merge(
                  'db.statement' =>  OpenTelemetry::Adapters::Dalli::Utils.format_command(op, args)
                ),
                kind: :client
              ) do
                super
              end
            end

            private
           

            def client_attributes(options)
              {
                'db.type' => 'memcached',
                'db.instance' => name,
                'db.url' => "#{hostname}:#{port}",
                'net.peer.name' => hostname,
                'net.peer.port' => port
              }
            end

            def tracer
              Dalli::Adapter.instance.tracer
            end
          end
        end
      end
    end
  end
end
