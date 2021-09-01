class AddFractionColumnToLeaves < ActiveRecord::Migration[4.2]
  def change
    add_column :user_leaves, :fractional_leave, :float
  end
end
