module SandthornDriverSequel2
  class Storage
    # = Storage
    # Abstracts access to contextualized database tables.
    #
    # == Rationale
    # Provide object-oriented access to the different tables to other objects.
    # Make it unnecessary for them to know about the current context.
    include EventStoreContext

    attr_reader :db

    def initialize(db, context, file_output_options)
      @db = db
      @context = context
      @event_file = File.open(file_output_options[:events_file_path], "a") if file_output_options[:events_file_path]
      last_event = events_table.order(:sequence_number).limit(1).last
      last_sequence_number = last_event ? last_event[:sequence_number] : 0

      if @event_file
        if file_output_options[:delimiter]
          @event_file_output_wrapper = FileOutputWrapper::Events.new @event_file, last_sequence_number, delimiter: file_output_options[:delimiter]
        else
          @event_file_output_wrapper = FileOutputWrapper::Events.new @event_file, last_sequence_number
        end
      end

    end

    # Returns a Sequel::Model for accessing events
    def events
      agg = Class.new(Sequel::Model(events_table))
      return @event_file_output_wrapper.events agg if @event_file
      agg
    end

    # Returns a Sequel::Model for accessing snapshots
    def snapshots
      Class.new(Sequel::Model(snapshots_table))
    end

    def events_table
      db[events_table_name]
    end

    def snapshots_table
      db[snapshots_table_name]
    end

  end
end