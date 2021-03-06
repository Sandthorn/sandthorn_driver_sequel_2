require 'spec_helper'

module SandthornDriverSequel2

  describe Storage do
    let(:context) { :test }
    before do
      prepare_for_test(context: context)
    end
    let(:db) { Sequel.connect(event_store_url) }
    let(:driver) { SequelDriver.new(event_store_url)}
    let(:storage) { Storage.new(db, context, {}) }

    # describe "anonymous aggegrate class" do
    #   it "can insert and read data" do
    #     create_aggregate
    #     aggregate = storage.aggregates.first(aggregate_id: "foo", aggregate_type: "Foo")
    #     expect(aggregate).to_not be_nil
    #   end

    #   it "can update data" do
    #     create_aggregate
    #     storage.aggregates.where(aggregate_id: "foo").update(aggregate_version: 2)
    #     aggregate = storage.aggregates.first(aggregate_id: "foo")
    #     expect(aggregate.aggregate_version).to eq(2)
    #   end
    # end

    describe "anonymous event class" do
      it "can insert and read data" do
        data, event_id = create_event
        event = storage.events.first(sequence_number: event_id).values
        expected = data.merge(sequence_number: event_id)
        expected_time = expected.delete(:timestamp)
        actual_time = event.delete(:timestamp)
        expect(event).to eq(expected)
        expect(actual_time.to_i).to eq(actual_time.to_i)
      end

      it "can update data" do
        data, event_id = create_event
        storage.events.where(sequence_number: event_id).update(event_name: "qux")
        event = storage.events.first(sequence_number: event_id)
        expect(event.event_name).to eq("qux")
      end
    end

    # def create_aggregate
    #   storage.aggregates.insert(aggregate_id: "foo", aggregate_type: "Foo")
    # end

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
      return data, event_id
    end

  end
end
