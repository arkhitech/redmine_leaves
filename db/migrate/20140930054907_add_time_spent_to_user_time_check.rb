class AddTimeSpentToUserTimeCheck < ActiveRecord::Migration[4.2]
  def change
    add_column :user_time_checks, :time_spent, :int
  end
end
