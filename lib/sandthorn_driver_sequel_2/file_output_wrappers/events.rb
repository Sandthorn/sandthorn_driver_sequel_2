require 'forwardable'

module SandthornDriverSequel2
  module FileOutputWrapper
    class Events
      extend Forwardable
      def initialize event_file, sequence_number
        @event_file = event_file
        @sequence_number = sequence_number
      end

      def events sequel
        @sequel = sequel
        self
      end

      def insert *args
        args.each do |event|
          @sequence_number += 1
          event_data = String.new("#{event[:event_data]}")
          event_data = " #{event_data}" if event_data =~ /^[\n\r]/
          @event_file.puts "#{@sequence_number};#{event[:aggregate_id]};#{event[:aggregate_version]};#{event[:aggregate_type]};#{event[:event_name]};#{event_data};#{event[:timestamp]}"
        end
      end

      def_delegators :@sequel, :first, :where, :join, :select, :all

      def save *args
        @event_file.write args
      end

      def flush
        @event_file.flush
      end
    end
  end
end  