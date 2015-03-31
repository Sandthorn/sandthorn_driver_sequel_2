require 'delegate'
module SandthornDriverSequel2
  class EventWrapper < SimpleDelegator

    [:aggregate_version, :event_name, :event_data, :timestamp, :aggregate_id, :aggregate_type].each do |attribute|
      define_method(attribute) do
        fetch(attribute)
      end
    end

  end
end