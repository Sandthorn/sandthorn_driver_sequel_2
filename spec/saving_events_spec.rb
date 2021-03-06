require 'spec_helper'
require 'msgpack'

module SandthornDriverSequel2
	describe EventStore do
		before(:each) { prepare_for_test }
		context "when saving a prefectly sane event stream" do
			let(:test_events) do
				e = []
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
				e << {aggregate_version: 2, event_name: "foo", event_args: ["bar"], event_data: "noop"}
				e << {aggregate_version: 3, event_name: "flubber", event_args: ["bar"] , event_data: "noop"}
			end

      let(:aggregate_id) { "c0456e26-e29a-4f67-92fa-130b3a31a39a" }

      it "should be able to save and retrieve events on the aggregate" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.get_aggregate_events aggregate_id
				expect(events.length).to eql test_events.length
			end

			it "should have correct keys when asking for events" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.get_aggregate aggregate_id, String
				event = events.first
				expect(event[:event_data]).to eql(test_events.first[:event_data])
        expect(event[:event_name]).to eql("new")
        expect(event[:aggregate_id]).to eql aggregate_id
        expect(event[:aggregate_version]).to eql 1
        expect(event[:sequence_number]).to be_a(Fixnum)
        expect(event[:timestamp]).to be_a(Time)
			end
    end

		context "when saving two aggregate types" do
			let(:test_events_1) do
				e = []
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
				e << {aggregate_version: 2, event_name: "foo", event_args: "bar", event_data: "noop"}
				e << {aggregate_version: 3, event_name: "flubber", event_args: "bar", event_data: "noop"}
			end
			let(:test_events_2) do
				e = []
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
			end
			let(:aggregate_id_1) {"c0456e26-e29a-4f67-92fa-130b3a31a39a"}
			let(:aggregate_id_2) {"c0456e26-e92b-4f67-92fa-130b3a31b93b"}
			let(:aggregate_id_3) {"c0456e26-e92b-1234-92fa-130b3a31b93b"}

			before(:each) do
				event_store.save_events test_events_1, aggregate_id_1, String
				event_store.save_events test_events_2, aggregate_id_2, Hash
				event_store.save_events test_events_2, aggregate_id_3, String
      end

			# it "both types should exist in get_all_typenames in alphabetical order" do
			# 	names = event_store.get_all_types
			# 	expect(names.length).to eql 2
			# 	expect(names.first).to eql "Hash"
			# 	expect(names.last).to eql "String"
   #    end

			# it "should list the aggregate ids when asking for get_aggregate_list_by_typename" do
			# 	ids = event_store.get_aggregate_ids(aggregate_type: String)
			# 	expect(ids.length).to eql 2
			# 	expect(ids.any? { |e| e == aggregate_id_1 }).to be_truthy
			# 	expect(ids.any? { |e| e == aggregate_id_3 }).to be_truthy
			# end
    end

		context "when saving events that are serilized with msgpack" do
			let(:test_data) { {name: "test", hash: {t: 123}} }
			let(:test_events) do
				e = []
				data = MessagePack.pack(test_data, symbolize_keys: true)
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: data}
			end
			let(:aggregate_id_1) {"c0456e26-e29a-4f67-92fa-130b3a31a39a"}

			it "should save and get events that are serialized with msgpack" do
				event_store.save_events test_events, aggregate_id_1, String
				events = event_store.get_aggregate aggregate_id_1, String
				expect(MessagePack.unpack(events.first[:event_data], symbolize_keys: true)).to eql test_data
      end

		end

	end
end
