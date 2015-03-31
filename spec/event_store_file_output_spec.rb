require 'spec_helper'
module SandthornDriverSequel2
	describe EventStore do
		before(:each) { prepare_for_test context: nil; }
		#after(:each) {File.delete(aggregates_file); File.delete(events_file);}
		let(:events_file) {"spec/db_file/test_events.csv"}
		let(:aggregates_file) {"spec/db_file/test_aggregates.csv"}
		let(:event_store_file_output) { EventStore.new url: event_store_url, file_output: {aggregates: aggregates_file, events: events_file} }
		
		let(:test_events) do
				e = [] 
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
				e << {aggregate_version: 2, event_name: "foo", event_args: ["bar"], event_data: "noop"}
				e << {aggregate_version: 3, event_name: "flubber", event_args: ["bar"] , event_data: "noop"}
			end
		let(:aggregate_id) {"c0456e26-e29a-4f67-92fa-130b3a31a39b"}



		context("when saving to a event_store that store its data to file") do
			
			before(:each) { event_store_file_output.save_events test_events, aggregate_id, String }
				
			it "should store but not find" do
				event_store_file_output.save_events test_events, aggregate_id, String
				expect(event_store_file_output.get_aggregate_events(aggregate_id)).to eq([])
			end
			# it "should output one line to aggregates file" do
			# 	event_store_file_output.save_events test_events, aggregate_id, String
				
			# 	fd = File.open aggregates_file
				
			# 	l = 0
			# 	puts "!!!!!"
			# 	fd.each do |line|
			# 		l += 1
			# 		puts "HERE!!! #{line}"
			# 	end
			# 	expect(l).to eql 1

			# end
		end
	end
end