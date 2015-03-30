module SandthornDriverSequel
  module FileOutputWrapper
    class Events
      def initialize event_file, sequence_number
        @event_file = event_file
        #@sequel = sequel
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

      def save *args
        @event_file.write args
      end

      def first *args
        @sequel.first *args
      end

      def where *args
        @sequel.where *args
      end

      def join *args
        @sequel.join *args
      end

      def select *args
        @sequel.select *args
      end

      def all *args
        @sequel.all *args
      end

      def flush
        @event_file.flush
      end



    end
  end
end  