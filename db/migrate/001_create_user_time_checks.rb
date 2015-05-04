class CreateUserTimeChecks < ActiveRecord::Migration
  def change
    create_table :user_time_checks do |t|
      t.references :user, indexed: true
      t.datetime :check_in_time   
      t.datetime :check_out_time 
    end
  end
end
