require "sandthorn_driver_sequel_2/version"
require "sandthorn_driver_sequel_2/utilities"
require "sandthorn_driver_sequel_2/wrappers"
require "sandthorn_driver_sequel_2/event_query"
require "sandthorn_driver_sequel_2/event_store_context"
require "sandthorn_driver_sequel_2/access"
require "sandthorn_driver_sequel_2/storage"
require 'sandthorn_driver_sequel_2/event_store'
require 'sandthorn_driver_sequel_2/errors'
require 'sandthorn_driver_sequel_2/migration'
require 'sandthorn_driver_sequel_2/file_output_wrappers/events'

module SandthornDriverSequel2
  class << self
    def driver_from_url url: nil, context: nil, file_output_options: {}
      EventStore.new url: url, context: context, file_output_options: file_output_options
    end
    def migrate_db url: nil, context: nil
      migrator = Migration.new url: url, context: context
      migrator.migrate!
    end
  end
end

