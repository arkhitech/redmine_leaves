class CreateTimeChecks < ActiveRecord::Migration
  def change
    create_table :time_checks do |t|
      t.integer :user_id, indexed: true
      t.datetime :check_in_time
      t.datetime :check_out_time
    end
  end
end
