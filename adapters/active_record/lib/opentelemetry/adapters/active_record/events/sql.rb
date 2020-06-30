require 'opentelemetry/adapters/active_record/event'
require 'opentelemetry/adapters/active_record/utils'


module OpenTelemetry
  module Adapters
    module ActiveRecord
      module Events
        # Defines instrumentation for sql.active_record event
        module SQL
          include ActiveRecord::Event

          EVENT_NAME = 'sql.active_record'.freeze
          PAYLOAD_CACHE = 'CACHE'.freeze

          module_function

          def event_name
            self::EVENT_NAME
          end

          def span_name
            'active_record.sql'.freeze
          end

          def process(span, event, _id, payload)
            config = OpenTelemetry::Adapters::ActiveRecord::Utils.connection_config(payload[:connection], payload[:connection_id])
            adapter_name = OpenTelemetry::Adapters::ActiveRecord::Utils.adapter_name
            # service_name = if settings.service_name != Datadog::Utils::Database::VENDOR_DEFAULT
            #                  settings.service_name
            #                else
            #                  adapter_name
            #                end

            # span.service = service_name
            span.name = "#{adapter_name}.query - #{payload.fetch(:sql)}"
            # span.kind = :client

            # Find out if the SQL query has been cached in this request. This meta is really
            # helpful to users because some spans may have 0ns of duration because the query
            # is simply cached from memory, so the notification is fired with start == finish.
            cached = payload[:cached] || (payload[:name] == PAYLOAD_CACHE)

            # span.set_attribute(Ext::TAG_DB_VENDOR, adapter_name)
            span.set_attribute("db.instance", config[:database])
            span.set_attribute("db.statement", payload.fetch(:sql))
            span.set_attribute("db.type", "sql")
            span.set_attribute("db.type", "sql")
            span.set_attribute("db.cached", cached) if cached
            span.set_attribute("db.url", config[:host]) if config[:host]
            span.set_attribute("db.port", config[:port]) if config[:port]
          rescue StandardError => e
            OpenTelemetry.logger.debug(e.message)
          end
        end
      end
    end
  end
end