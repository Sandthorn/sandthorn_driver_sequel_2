require 'spec_helper'

module SandthornDriverSequel2

  describe Storage do

    context "ToFile" do

      let(:context) { :test }
      let(:event_file) { "spec/db_file/events.csv" }

      before do
        prepare_for_test(context: context)
      end
      after(:each) do
        File.delete(event_file)
      end
      let(:db) { Sequel.connect(event_store_url) }
      let(:driver) { SequelDriver.new(event_store_url)}
      let(:storage) { Storage.new(db, context, file_output: { events: event_file}) }

      describe "anonymous event class" do
        it "insert no data to the db" do
          data, event_id = create_event
          event = storage.events.first
          
          expect(event).to be_nil
        end

        it "can read data from file" do
          data, event_id = create_event
          file = File.open event_file
          expect(file.first).to eq("1;foo;1;Foo;foo;bar;#{data[:timestamp]}\n")
        end
      end

      def create_event
        data = {
            aggregate_id: "foo",
            aggregate_version: 1,
            aggregate_type: "Foo",
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