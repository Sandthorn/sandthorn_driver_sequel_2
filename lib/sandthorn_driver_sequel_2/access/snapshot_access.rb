module SandthornDriverSequel2
  class SnapshotAccess < Access::Base

    def find_by_aggregate_id(aggregate_id)
      storage.snapshots.first(aggregate_id: aggregate_id)
    end

    def find(snapshot_id)
      storage.snapshots[snapshot_id]
    end

    def record_snapshot(aggregate_id, snapshot_data)
      raise SandthornDriverSequel2::Errors::SnapshotDataError unless perform_snapshot?(snapshot_data)
      
      previous_snapshot = find_by_aggregate_id(aggregate_id)
      if previous_snapshot
        return  if previous_snapshot[:aggregate_version] == snapshot_data[:aggregate_version]
      end
      perform_snapshot(aggregate_id, previous_snapshot, snapshot_data)
    end

    private

    def perform_snapshot?(snapshot_data)
      return false if snapshot_data.nil?
      return false unless snapshot_data.class == Hash
      return false if snapshot_data[:aggregate_version].nil?
      return false if snapshot_data[:event_data].nil?
      return true
    end

    def perform_snapshot(aggregate_id, previous_snapshot, snapshot_data)
      if valid_snapshot?(previous_snapshot)
        update_snapshot(previous_snapshot, snapshot_data)
      else
        insert_snapshot(aggregate_id, snapshot_data)
      end
    end

    def insert_snapshot(aggregate_id, snapshot_data)
      data = build_snapshot(snapshot_data)
      data[:aggregate_id] = aggregate_id
      storage.snapshots.insert(data)
    end

    def build_snapshot(snapshot_data)
      snapshot_data = SnapshotWrapper.new(snapshot_data)
      {
          snapshot_data:      snapshot_data.data,
          aggregate_version:  snapshot_data.aggregate_version
        #  aggregate_type:     snapshot_data.aggregate_version
      }
    end

    def valid_snapshot?(snapshot)
      snapshot && snapshot[:snapshot_data]
    end

    def update_snapshot(snapshot, snapshot_data)
      data = build_snapshot(snapshot_data)
      storage.snapshots.where(id: snapshot.id).update(data)
    end

  end
end
