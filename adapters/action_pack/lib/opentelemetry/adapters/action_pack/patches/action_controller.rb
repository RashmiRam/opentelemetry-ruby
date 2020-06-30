module OpenTelemetry
  module Adapters
    module ActionPack
      module Patches
        # Module to prepend to ActionController::Metal for instrumentation
        module ActionController
          module Metal
            def process_action(*args)
              # mutable payload with a tracing context that is used in two different
              # signals; it propagates the request span so that it can be finished
              # no matter what
              payload = {
                controller: self.class,
                action: action_name,
                env: request.env,
                headers: {
                  # The exception this controller was given in the request,
                  # which is typical if the controller is configured to handle exceptions.
                  request_exception: request.headers['action_dispatch.exception']
                },
                tracing_context: {}
              }

              begin
                # process and catch request exceptions
                span = tracer.start_span(
                  "#{self.class}::#{action_name}",
                  attributes: {
                    # 'component' => 'http',
                    # 'http.method' => http_method,
                    # 'http.url' => url
                  },
                  kind: :internal
                )
                 # attach the current span to the tracing context
                tracing_context = payload.fetch(:tracing_context)
                tracing_context[:otel_request_span] = span
                tracer.with_span(span) do 
                  result = super(*args)
                  status = response_status
                  payload[:status] = status unless status.nil?
                  result
                end
                
              # rubocop:disable Lint/RescueException
              rescue Exception => e
                payload[:exception] = [e.class.name, e.message]
                payload[:exception_object] = e
                raise e
              end
            # rubocop:enable Lint/RescueException
            ensure
              finish_processing(payload)
            end

            def finish_processing(payload)
              # retrieve the tracing context and the latest active span
              tracing_context = payload.fetch(:tracing_context)
              env = payload.fetch(:env)
              span = tracing_context[:otel_request_span]
              return unless span && span.recording?

              begin
                # Set the resource name, if it's still the default name
                # if span.resource == span.name
                #   span.resource = "#{payload.fetch(:controller)}##{payload.fetch(:action)}"
                # end

                # Set the resource name of the Rack request span.
                # rack_request_span = env[Datadog::Contrib::Rack::TraceMiddleware::RACK_REQUEST_SPAN]
                # rack_request_span.resource = span.resource if rack_request_span
          
                # span.set_attribute("action", payload.fetch(:action))
                # span.set_attribute("controller", payload.fetch(:controller))

                exception = payload[:exception_object]
                if exception.nil?
                  # [christian] in some cases :status is not defined,
                  # rather than firing an error, simply acknowledge we don't know it.
                  status = payload.fetch(:status, '?').to_s
                  span.status = 1 if status.starts_with?('5')
                elsif Utils.exception_is_error?(exception)
                  span.set_error(exception)
                end
              ensure
                span.finish
              end
            rescue StandardError => e
              raise e
            end

            def tracer
              ActionPack::Adapter.instance.tracer
            end

            def response_status
              case response
              when ::ActionDispatch::Response
                response.status
              when Array
                # Likely a Rack response array: first element is the status.
                status = response.first
                status.class <= Integer ? status : nil
              end
            end
          end
        end
      end
    end
  end
end
