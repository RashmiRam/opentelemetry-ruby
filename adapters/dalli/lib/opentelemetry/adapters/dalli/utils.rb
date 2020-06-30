# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Adapters
    module Dalli
      # Utility functions
      module Utils
        extend self

        def format_command(operation, args)
          placeholder = "#{operation} BLOB (OMITTED)"
          command = [operation, *args].join(' ').strip
          command = utf8_encode(command, binary: true, placeholder: placeholder)
          truncate(command, 100)
        rescue => e
          OpenTelemetry.logger.debug("Error sanitizing Dalli operation: #{e}")
          placeholder
        end

        def span_name(operation)
          placeholder = "#{operation} BLOB (OMITTED)"
          chars = operation.to_s.gsub(/^async/, "").gsub(/^CAS/, "cas")
          chars[0] = chars[0].downcase
          "Dalli::Client - #{chars}"
        rescue => e
          OpenTelemetry.logger.debug("Error sanitizing Dalli operation: #{e}")
          placeholder
        end

        def self.truncate(value, size, omission = '...'.freeze)
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

	    def self.utf8_encode(str, options = {})
	      str = str.to_s

	      if options[:binary]
	        # This option is useful for "gracefully" displaying binary data that
	        # often contains text such as marshalled objects
	        str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
	      elsif str.encoding == ::Encoding::UTF_8
	        str
	      else
	        str.encode(::Encoding::UTF_8)
	      end
	    rescue => e
	      OpenTelemetry.logger.debug("Error encoding string in UTF-8: #{e}")

	      options.fetch(:placeholder, STRING_PLACEHOLDER)
	    end
 
      end
    end
  end
end
