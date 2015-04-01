module SandthornDriverSequel2
  class EventStore
    include EventStoreContext

    attr_reader :driver, :context, :url

    def initialize url: nil, context: nil, events_file_path: nil
      @driver = SequelDriver.new url: url
      @context = context
      @url = url

      driver.execute do |db|
        @storage = Storage.new(db, context, events_file_path)
      end
    end

    def save_events events, aggregate_id, class_name
      driver.execute_in_transaction do |db|
        event_access = get_event_access(db)
        events = events.map { |event| event[:aggregate_type] = class_name; event[:aggregate_id] = aggregate_id; event;}
        event_access.store_events(events)
      end
    end

    def get_aggregate_events(aggregate_id)
      driver.execute do |db|
        events = get_event_access(db)
        events.find_events_by_aggregate_id(aggregate_id)
      end
    end

    def save_snapshot aggregate_snapshot, aggregate_id
      driver.execute_in_transaction do |db|
        snapshot_access = get_snapshot_access(db)
        snapshot_access.record_snapshot(aggregate_id, aggregate_snapshot)
      end
    end

    # If the aggregate has a snapshot, return events starting from the snapshots.
    # Otherwise, return all events.
    # TODO: needs a better name
    def get_aggregate_events_from_snapshot(aggregate_id)
      driver.execute do |db|
        #snapshots = get_snapshot_access(db)
        event_access = get_event_access(db)
        snapshot = false#snapshots.find_by_aggregate_id(aggregate_id)
        if snapshot
          events = event_access.after_snapshot(snapshot)
          snapshot_event = build_snapshot_event(snapshot)
          events.unshift(snapshot_event)
        else
          event_access.find_events_by_aggregate_id(aggregate_id)
        end
      end
    end

    def build_snapshot_event(snapshot)
      {
          aggregate_version: snapshot[:aggregate_version],
          event_data: snapshot[:snapshot_data],
          event_name: "aggregate_set_from_snapshot"
      }
    end

    def get_aggregate aggregate_id, *class_name
      warn(":get_aggregate is deprecated. Use :get_aggregate_events_from_snapshot")
      get_aggregate_events_from_snapshot(aggregate_id)
    end

    def get_aggregate_ids(aggregate_type: nil)
      driver.execute do |db|
        access = get_event_access(db)
        access.aggregate_ids(aggregate_type: aggregate_type)
      end
    end

    def get_aggregate_list_by_typename(type)
      warn(":get_aggregate_list_by_typenames is deprecated. Use :get_aggregate_ids")
      get_aggregate_ids(type: type)
    end

    # def get_all_types
    #   driver.execute do |db|
    #     access = get_aggregate_access(db)
    #     access.aggregate_types
    #   end
    # end

    def get_snapshot aggregate_id
      driver.execute do |db|
        snapshots = get_snapshot_access(db)
        snapshot = snapshots.find_by_aggregate_id(aggregate_id)
        transform_snapshot(snapshot)
      end
    end

    def get_events(*args)
      driver.execute do |db|
        event_access = get_event_access(db)
        event_access.get_events(*args)
      end
    end

    def get_new_events_after_event_id_matching_classname event_id, class_name, take: 0
      get_events(after_sequence_number: event_id, aggregate_types: Utilities.array_wrap(class_name), take: take)
    end

    def obsolete_snapshots(*args)
      driver.execute do |db|
        snapshots = get_snapshot_access(db)
        snapshots.obsolete(*args)
      end
    end

    private

    def transform_snapshot(snapshot)
      {
          aggregate_version: snapshot.aggregate_version,
          event_data: snapshot.snapshot_data
      }
    end

    def get_event_access(db)
      EventAccess.new(storage(db))
    end

    def get_snapshot_access(db)
      SnapshotAccess.new(storage(db))
    end

    def storage(db)
      @storage
      #Storage.new(db, context, file_output: @file_output)
    end

  end
end