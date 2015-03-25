require 'spec_helper'

module SandthornDriverSequel

  describe Storage do

    context "ToFile" do

      let(:context) { :test }
      let(:aggregate_file) { "spec/db_file/aggregates.csv" }
      let(:event_file) { "spec/db_file/events.csv" }

      before do
        prepare_for_test(context: context)
      end
      after(:each) do
        File.delete(aggregate_file)
        File.delete(event_file)
      end
      let(:db) { Sequel.connect(event_store_url) }
      let(:driver) { SequelDriver.new(event_store_url)}
      let(:storage) { Storage.new(db, context, file_output: {aggregates: aggregate_file, events: event_file}) }

      describe "anonymous aggegrate class" do
        it "should not store data to the db" do
          create_aggregate
          aggregate = storage.aggregates.first(aggregate_id: "foo", aggregate_type: "Foo")
          expect(aggregate).to be_nil
        end

        it "should not update data to the db" do
          create_aggregate
          storage.aggregates.where(aggregate_id: "foo").update(aggregate_version: 2)
          aggregate = storage.aggregates.first(aggregate_id: "foo")
          expect(aggregate).to be_nil
        end

        it "should store data to file" do
          create_aggregate
          create_aggregate_two

          file = File.open aggregate_file
          expect(file.first).to eq("foo, Foo\n")
          expect(file.first).to eq("foo2, Foo\n")
        end
      end

      describe "anonymous event class" do
        it "insert no data to the db" do
          data, event_id = create_event
          event = storage.events.first
          
          expect(event).to be_nil
        end

        it "can read data from file" do
          data, event_id = create_event
          file = File.open event_file
          expect(file.first).to eq("foo, 1, foo, bar, #{data[:timestamp]}\n")
        end
      end

      def create_aggregate
        storage.aggregates.insert(aggregate_id: "foo", aggregate_type: "Foo")
        storage.aggregates.flush
      end

      def create_aggregate_two
        storage.aggregates.insert(aggregate_id: "foo2", aggregate_type: "Foo")
        storage.aggregates.flush
      end

      def create_event
        aggregate_table_id = create_aggregate
        data = {
            aggregate_id: "foo",
            aggregate_version: 1,
            event_name: "foo",
            event_data: "bar",
            timestamp: Time.now.utc
        }
        event_id = storage.events.insert(data)
        storage.events.flush
        return data, event_id
      end

    end
  end
end