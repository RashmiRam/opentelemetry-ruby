# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Adapters
    module ActiveSupport
      # class Railtie < Rails::Railtie
      #   initializer 'opentelemetry.before_initialize' do |app|
      #     app.middleware.insert_before(0, OpenTelemetry::Adapters::Rack::Middlewares::TracerMiddleware)

      #   end
      # end
      # The Adapter class contains logic to detect and install the Rails
      # instrumentation adapter
      class Adapter < OpenTelemetry::Instrumentation::Adapter
        install do |_config|
          require_dependencies
          patch_active_support
        end

        present do
          defined?(::ActiveSupport)
        end

        private

        def require_dependencies
          require_relative 'patches/active_support'
        end

        def patch_redis?(meth)
           defined?(::ActiveSupport::Cache::RedisStore) \
            && ::ActiveSupport::Cache::RedisStore.instance_methods(false).include?(meth)
        end

        def patch_dalli?(meth)
          defined?(ActiveSupport::Cache::MemCacheStore) && ::ActiveSupport::Cache::MemCacheStore.instance_methods(false).include?(meth)
        end

        def cache_store_class(meth)
          if patch_redis?(meth)
            ::ActiveSupport::Cache::RedisStore
          elsif patch_dalli?(meth)
            OpenTelemetry.logger.error("Dalli is enabled in FD support")
            ::ActiveSupport::Cache::MemCacheStore
          else
            ::ActiveSupport::Cache::Store
          end
        end

        def patch_active_support
          patch_cache_store_read
          patch_cache_store_fetch
          patch_cache_store_write
          patch_cache_store_delete
        end

        def patch_cache_store_read
          cache_store_class(:read).send(:prepend, Patches::Cache::Read)
        end

        def patch_cache_store_fetch
          cache_store_class(:fetch).send(:prepend, Patches::Cache::Fetch)
        end

        def patch_cache_store_write
          cache_store_class(:write).send(:prepend, Patches::Cache::Write)
        end

        def patch_cache_store_delete
          cache_store_class(:delete).send(:prepend, Patches::Cache::Delete)
        end
      end
    end
  end
end
