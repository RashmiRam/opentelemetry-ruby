# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'

module OpenTelemetry
  module Adapters
    # Contains the OpenTelemetry instrumentation adapter for the Rails gem
    module ActionPack
    end
  end
end

require_relative './action_pack/adapter'
require_relative './action_pack/version'
