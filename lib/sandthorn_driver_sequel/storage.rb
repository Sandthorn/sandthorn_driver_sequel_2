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

    # Returns a Sequel::Model for accessing aggregates
    def aggregates
      agg = Class.new(Sequel::Model(aggregates_table))
      return FileOutputWrapper::Aggregates.new @aggregate_file, agg if @aggregate_file
      agg
    end

    # Returns a Sequel::Model for accessing events
    def events
      agg = Class.new(Sequel::Model(events_table))
      return FileOutputWrapper::Events.new @event_file, agg if @event_file
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