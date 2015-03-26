module SandthornDriverSequel
  module FileOutputWrapper
    class Aggregates
      def initialize aggregate_file, sequel
        @aggregate_file = aggregate_file
        @sequel = sequel
      end

      def insert *args
        args.each do |event|
          @aggregate_file.puts "#{event[:aggregate_id]}, #{event[:aggregate_type]}"
        end
      end

      def save *args
        @aggregate_file.write args
      end

      def first *args
        @sequel.first *args
      end

      def where *args
        @sequel.where *args
      end

      def flush
        @aggregate_file.flush
      end

    end
  end
end