# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'

module OpenTelemetry
  module Adapters
    # Contains the OpenTelemetry instrumentation adapter for the Rails gem
    module ActiveRecord
    end
  end
end

require_relative './active_record/adapter'
require_relative './active_record/version'
