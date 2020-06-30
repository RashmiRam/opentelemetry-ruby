require 'opentelemetry/adapters/active_support/notifications/event'

module OpenTelemetry
  module Adapters
    module ActiveRecord
      # Defines basic behaviors for an ActiveRecord event.
      module Event
        def self.included(base)
          base.send(:include, ActiveSupport::Notifications::Event)
          # base.send(:extend, ClassMethods)
        end

        # Class methods for ActiveRecord events.
        # module ClassMethods
        #   # def span_options
        #   #   { service: configuration[:service_name] }
        #   # end

        #   # def tracer
        #   #   -> { configuration[:tracer] }
        #   # end
        # end
      end
    end
  end
end