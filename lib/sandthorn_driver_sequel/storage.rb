module SandthornDriverSequel
  class Storage
    # = Storage
    # Abstracts access to contextualized database tables.
    #
    # == Rationale
    # Provide object-oriented access to the different tables to other objects.
    # Make it unnecessary for them to know about the current context.
    include EventStoreContext

    attr_reader :db

    def initialize(db, context, file_output: {})
      @db = db
      @context = context
      @file_output = file_output
      @aggregate_file = File.open(file_output[:aggregates], "w") if file_output[:aggregates]
      @event_file = File.open(file_output[:events], "w") if file_output[:events]
    end

    class AggregateMock
      def initialize aggregate_file, sequel
        @aggregate_file = aggregate_file
        @sequel = sequel
      end

      def insert *args
        @aggregate_file.puts "#{args.first[:aggregate_id]}, #{args.first[:aggregate_type]}"
       # @sequel.insert *args
      end

      def save *args
        @aggregate_file.write args
       # @sequel.save *args
      end

      def first *args
        @sequel.first *args
      end

      def where *args
        @sequel.where *args
      end

      def flush
        @aggregate_file.flush
      end

      # def self.method_missing(method_sym, *arguments, &block)
      #   puts "method_missingh !!!! #{method_sym}, #{arguments}, #{block}"
      #   sequel.send(method_sym, arguments) 
      # end
    end

    class EventMock
      def initialize event_file, sequel
        @event_file = event_file
        @sequel = sequel
      end

      def insert *args
        args.each do |event|
          @event_file.puts "#{event[:aggregate_id]}, #{event[:aggregate_version]}, #{event[:event_name]}, #{event[:event_data]}, #{event[:timestamp]}"
        end
      end

      def save *args
        @event_file.write args
      end

      def first *args
        @sequel.first *args
      end

      def where *args
        @sequel.where *args
      end

      def flush
        @event_file.flush
      end

      # def self.method_missing(method_sym, *arguments, &block)
      #   puts "method_missingh !!!! #{method_sym}, #{arguments}, #{block}"
      #   sequel.send(method_sym, arguments) 
      # end
    end

    # Returns a Sequel::Model for accessing aggregates
    def aggregates
      agg = Class.new(Sequel::Model(aggregates_table))
      return AggregateMock.new @aggregate_file, agg if @aggregate_file
      agg
    end

    # Returns a Sequel::Model for accessing events
    def events
      agg = Class.new(Sequel::Model(events_table))
      return EventMock.new @event_file, agg if @event_file
      agg
    end

    # Returns a Sequel::Model for accessing snapshots
    def snapshots
      Class.new(Sequel::Model(snapshots_table))
    end

    def aggregates_table
      db[aggregates_table_name]
    end

    def events_table
      db[events_table_name]
    end

    def snapshots_table
      db[snapshots_table_name]
    end

  end
end