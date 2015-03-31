module SandthornDriverSequel2
  module Access
    class Base
      # = Access::Base
      # Inheriting classes use +storage+ to provide access to a
      # particular database model/table.
      def initialize(storage)
        @storage = storage
      end

      private

      attr_reader :storage
    end
  end
end

require "sandthorn_driver_sequel_2/access/event_access"
require "sandthorn_driver_sequel_2/access/snapshot_access"