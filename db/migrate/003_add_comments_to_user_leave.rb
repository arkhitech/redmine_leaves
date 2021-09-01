class AddCommentsToUserLeave < ActiveRecord::Migration[4.2]
  def change
    add_column :user_leaves, :comments, :string
  end
end