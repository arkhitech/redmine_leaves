class AddFractionColumnToLeaves < ActiveRecord::Migration
  def change
    add_column :user_leaves, :fractional_leave, :float
  end
end
