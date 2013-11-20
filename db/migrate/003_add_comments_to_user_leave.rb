class AddCommentsToUserLeave < ActiveRecord::Migration
  def change
    add_column :user_leaves, :comments, :string
  end
end