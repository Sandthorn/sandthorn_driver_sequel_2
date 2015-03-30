module SandthornDriverSequel
  module FileOutputWrapper
    class Aggregates
      def initialize aggregate_file
        @aggregate_file = aggregate_file
        @file_cache = {}
      end

      def aggregates sequel
        @sequel = sequel
        self
      end

      def insert *args
        args.each do |aggregate|
          #@aggregate_file.puts "#{aggregate[:aggregate_id]}, #{aggregate[:aggregate_type]}"
          @file_cache[aggregate[:aggregate_id]] = aggregate
        end
        return args.first[:aggregate_id]
      end

      def [] *args
        return AggregateFile.new(@aggregate_file, @file_cache, @file_cache[args.first][:aggregate_id], @file_cache[args.first][:aggregate_type]) if @file_cache[args.first]
        @sequel[*args]
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

    class AggregateFile

      attr_accessor :aggregate_id, :aggregate_type, :aggregate_version

      def initialize aggregate_file, file_cache, aggregate_id, aggregate_type, aggregate_version: 0
        @aggregate_file = aggregate_file
        @file_cache = file_cache
        @aggregate_id = aggregate_id
        @aggregate_type = aggregate_type
        @aggregate_version = aggregate_version
      end

      def save
        @file_cache[:aggregate_id] = {aggregate_id: @aggregate_id, aggregate_version: @aggregate_version, aggregate_type: @aggregate_type}
        @aggregate_file.puts "#{@aggregate_id};#{@aggregate_type};#{@aggregate_version}"
      end
    end
    AggregateObject = Struct.new(:aggregate_id, :aggregate_version)
  end
end