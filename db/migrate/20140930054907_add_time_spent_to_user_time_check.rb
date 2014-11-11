class AddTimeSpentToUserTimeCheck < ActiveRecord::Migration
  def change
    add_column :user_time_checks, :time_spent, :int
  end
end
