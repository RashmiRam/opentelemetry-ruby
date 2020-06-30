require 'opentelemetry/adapters/active_record/event'

module OpenTelemetry
  module Adapters
    module ActiveRecord
      module Events
        # Defines instrumentation for instantiation.active_record event
        module Instantiation
          include ActiveRecord::Event

          EVENT_NAME = 'instantiation.active_record'.freeze

          module_function

          def supported?
            Gem.loaded_specs['activerecord'] \
              && Gem.loaded_specs['activerecord'].version >= Gem::Version.new('4.2')
          end

          def event_name
            self::EVENT_NAME
          end

          def span_name
            'active_record.instantiation'.freeze
          end

          def process(span, event, _id, payload)
            # Inherit service name from parent, if available.
            # span.service = if configuration[:orm_service_name]
            #                  configuration[:orm_service_name]
            #                elsif span.parent
            #                  span.parent.service
            #                else
            #                  Ext::SERVICE_NAME
            #                end

            span.name = "#{span_name} #{payload.fetch(:class_name)}"
            # span.kind = :client
            # span.span_type = Ext::SPAN_TYPE_INSTANTIATION

            span.set_attribute("active_record.instantiation.class_name", payload.fetch(:class_name))
            span.set_attribute("active_record.instantiation.record_count", payload.fetch(:record_count))
          rescue StandardError => e
            OpenTelemetry.logger.debug(e.message)
          end
        end
      end
    end
  end
end