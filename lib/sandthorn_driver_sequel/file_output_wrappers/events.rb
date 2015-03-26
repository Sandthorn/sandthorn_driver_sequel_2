module SandthornDriverSequel
  module FileOutputWrapper
    class Events
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

    end
  end
end  