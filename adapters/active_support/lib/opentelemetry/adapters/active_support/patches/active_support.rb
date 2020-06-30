
module OpenTelemetry
  module Adapters
    module ActiveSupport
      module Patches
        module Cache  
          module_function

          def start_trace_cache(payload)
            # In most of the cases Rails ``fetch()`` and ``read()`` calls are nested.
            # This check ensures that two reads are not nested since they don't provide
            # interesting details.
            # NOTE: the ``finish_trace_cache()`` is fired but it already has a safe-guard
            # to avoid any kind of issue.
            current_span = tracer.current_span
            return if payload[:action] == 'GET' &&
                      current_span.try(:name) == "rails.cache GET"

            tracing_context = payload.fetch(:tracing_context)

            span = tracer.start_span("rails.cache #{payload[:action]}", kind: :internal)
            tracing_context[:otel_cache_span] = span
            span
          rescue StandardError => e
            raise e
          end

          def finish_trace_cache(payload)
            # retrieve the tracing context and continue the trace
            tracing_context = payload.fetch(:tracing_context)
            span = tracing_context[:otel_cache_span]
            return unless span && span.recording?

            begin
              # discard parameters from the cache_store configuration
              if defined?(::Rails)
                store, = *Array.wrap(::Rails.configuration.cache_store).flatten
                span.set_attribute('rails.cache.instance', store.to_s)
              end

              normalized_key = ::ActiveSupport::Cache.expand_cache_key(payload.fetch(:key))
              cache_key = truncate(normalized_key, 300)
              span.set_attribute('rails.cache.key', cache_key)

              span.set_error(payload[:exception]) if payload[:exception]
            ensure
              span.finish
            end
          rescue StandardError => e
            raise e
          end

          def truncate(value, size, omission = '...'.freeze)
            string = value.to_s

            return string if string.size <= size

            string = string.slice(0, size - 1)

            if size < omission.size
              string[0, size] = omission
            else
              string[size - omission.size, size] = omission
            end

            string
          end

          def tracer
            ActiveSupport::Adapter.instance.tracer
          end

          module Read
            def read(*args, &block)
              payload = {
                action: 'GET',
                key: args[0],
                tracing_context: {}
              }

              begin
                # process and catch cache exceptions
                span = Cache.start_trace_cache(payload)
                Cache.tracer.with_span(span) do 
                  super
                end
              rescue Exception => e
                payload[:exception] = [e.class.name, e.message]
                payload[:exception_object] = e
                raise e
              end
            ensure
              Cache.finish_trace_cache(payload)
            end
          end

              # Defines instrumentation for ActiveSupport cache fetching
          module Fetch
            def fetch(*args, &block)
              payload = {
                action: 'GET',
                key: args[0],
                tracing_context: {}
              }

              begin
                # process and catch cache exceptions
                span = Cache.start_trace_cache(payload)
                Cache.tracer.with_span(span) do 
                  super
                end
              rescue Exception => e
                payload[:exception] = [e.class.name, e.message]
                payload[:exception_object] = e
                raise e
              end
            ensure
              Cache.finish_trace_cache(payload)
            end
          end

          # Defines instrumentation for ActiveSupport cache writing
          module Write
            def write(*args, &block)
              payload = {
                action: 'SET',
                key: args[0],
                tracing_context: {}
              }

              begin
                # process and catch cache exceptions
                span = Cache.start_trace_cache(payload)
                Cache.tracer.with_span(span) do 
                  super
                end
              rescue Exception => e
                payload[:exception] = [e.class.name, e.message]
                payload[:exception_object] = e
                raise e
              end
            ensure
              Cache.finish_trace_cache(payload)
            end
          end

          # Defines instrumentation for ActiveSupport cache deleting
          module Delete
            def delete(*args, &block)
              payload = {
                action: 'DELETE',
                key: args[0],
                tracing_context: {}
              }

              begin
                # process and catch cache exceptions
                span = Cache.start_trace_cache(payload) 
                Cache.tracer.with_span(span) do 
                  super
                end
              rescue Exception => e
                payload[:exception] = [e.class.name, e.message]
                payload[:exception_object] = e
                raise e
              end
            ensure
              Cache.finish_trace_cache(payload)
            end
          end
        end
      end
    end
  end
end
