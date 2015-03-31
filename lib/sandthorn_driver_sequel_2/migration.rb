require 'sandthorn_driver_sequel_2/sequel_driver'
module SandthornDriverSequel2
  class Migration
    include EventStoreContext
    attr_reader :driver, :context
    def initialize url: nil, context: nil
      @driver = SequelDriver.new url: url
      @context = context
    end
    def migrate!
      ensure_migration_table!
      events
      snapshots
    end
    private
    def clear_for_test
      driver.execute do |db|
        db[snapshots_table_name].truncate
        db[events_table_name].truncate
      end
    end

    def events
      events_migration_0 = "#{events_table_name}-20130308"
      unless has_been_migrated?(events_migration_0)
        driver.execute_in_transaction do |db|
          db.create_table(events_table_name) do
            primary_key :sequence_number
            String :aggregate_id, fixed: true, size: 36, null: false
            Integer :aggregate_version, null: false
            String :aggregate_type, size: 255, null: false
            String :event_name, size: 255, null: false
            String :event_data, text: true, null: true
            DateTime :timestamp, null: false

            index [:aggregate_type]
            index [:event_name]
            index [:aggregate_id]
            index [:aggregate_id, :aggregate_version], unique: true
          end
          was_migrated events_migration_0, db
        end
      end
    end
    def snapshots
      snapshot_migration_0 = "#{snapshots_table_name}-20130312"
      unless has_been_migrated?(snapshot_migration_0)
        driver.execute_in_transaction do |db|
          db.create_table(snapshots_table_name) do
            primary_key :id
            Integer :aggregate_version, null: false
            String :snapshot_data, text: true, null: false
            String :aggregate_id, fixed: true, size: 36, null: false
            index [:aggregate_id], unique: true
          end
          was_migrated snapshot_migration_0, db
        end
      end
    end

    def migration_table_name
      :event_store_sequel_migrations
    end
    def ensure_migration_table!
      driver.execute do |db|
        db.create_table?(migration_table_name) do
          primary_key :id
          String :migration_name, null: false
          index [:migration_name], unique: true
          DateTime :timestamp, :null=>false
        end
      end
    end
    def has_been_migrated? migration_name
      driver.execute {|db| db[migration_table_name].all.any? { |e| e[:migration_name]==migration_name } }
    end
    def was_migrated migration_name, db
      db[migration_table_name].insert timestamp: Time.now.utc, migration_name: migration_name
    end
  end
end
