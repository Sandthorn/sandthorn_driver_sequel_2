module SandthornDriverSequel2
  class SnapshotWrapper < SimpleDelegator
    def aggregate_version
      self[:aggregate_version]
    end

    def data
      self[:event_data]
    end

    # def aggregate_type
    # 	self[:aggregate_type]
    # end
  end
end