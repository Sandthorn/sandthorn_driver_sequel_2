require "sandthorn_driver_sequel/version"
require "sandthorn_driver_sequel/utilities"
require "sandthorn_driver_sequel/wrappers"
require "sandthorn_driver_sequel/event_query"
require "sandthorn_driver_sequel/event_store_context"
require "sandthorn_driver_sequel/access"
require "sandthorn_driver_sequel/storage"
require 'sandthorn_driver_sequel/event_store'
require 'sandthorn_driver_sequel/errors'
require 'sandthorn_driver_sequel/migration'
require 'sandthorn_driver_sequel/file_output_wrappers/aggregates'
require 'sandthorn_driver_sequel/file_output_wrappers/events'

module SandthornDriverSequel
  class << self
    def driver_from_url url: nil, context: nil, file_output: {}
      EventStore.new url: url, context: context, file_output: file_output 
    end
    def migrate_db url: nil, context: nil
      migrator = Migration.new url: url, context: context
      migrator.migrate!
    end
  end
end

