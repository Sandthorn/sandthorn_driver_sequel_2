module SandthornDriverSequel
  class EventAccess < Access::Base
    # = EventAccess
    # Reads and writes events.

    def store_events(events)
      events = Utilities.array_wrap(events)
      timestamp = Time.now.utc
      events.each do |event|
        store_event(timestamp, event)
      end
      #puts aggregate.inspect
#      aggregate.save
    end

    def find_events_by_aggregate_id(aggregate_id)
      #aggregate_version = Sequel.qualify(storage.events_table_name, :aggregate_version)
      #aggregate_aggregate_id = Sequel.qualify(storage.aggregates_table_name, :aggregate_id)
      #events_aggregate_id = Sequel.qualify(storage.events_table_name, :aggregate_id)
      wrap(storage.events.where(:aggregate_id => aggregate_id)
        .select(
          :sequence_number,
          :aggregate_id,
          :aggregate_version,
          :aggregate_type,
          :event_name,
          :event_data,
          :timestamp)
        .order(:sequence_number)
        .all)
    end

    # Returns events that occurred after the given snapshot
    def after_snapshot(snapshot)
      _aggregate_version = snapshot.aggregate_version
      aggregate_id = snapshot.aggregate_id
      wrap(storage.events
        .where(aggregate_id: aggregate_id)
        .where { aggregate_version > _aggregate_version }.all)
    end

    def get_events(*args)
      query_builder = EventQuery.new(storage)
      query_builder.build(*args)
      wrap(query_builder.events)
    end

    # Returns aggregate ids.
    # @param aggregate_type, optional,
    def aggregate_ids(aggregate_type: nil)
      events = storage.events
      if aggregate_type
        events = events.where(aggregate_type: aggregate_type.to_s)
      end
      events.select_map(:aggregate_id).uniq
    end

    private

    def wrap(arg)
      events = Utilities.array_wrap(arg)
      events.map { |e| EventWrapper.new(e.values) }
    end

    def build_event_data(timestamp, event)
      {
          aggregate_id: event.aggregate_id,
          aggregate_version: event.aggregate_version,
          aggregate_type: event.aggregate_type.to_s,
          event_name: event.event_name,
          event_data: event.event_data,
          timestamp: timestamp
      }
    end

    def check_versions!(aggregate, event)
      version = aggregate.aggregate_version
      if version != event[:aggregate_version]
        raise Errors::ConcurrencyError.new(event, aggregate)
      end
    rescue TypeError
      raise Errors::EventFormatError, "Event has wrong format: #{event.inspect}"
    end

    def store_event(timestamp, event)
      event = EventWrapper.new(event)
      #aggregate.aggregate_version += 1
      #check_versions!(aggregate, event)
      data = build_event_data(timestamp, event)
      storage.events.insert(data)
    end

  end
end