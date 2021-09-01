class AddCommentsToUserTimeChecks < ActiveRecord::Migration[4.2]
  def change
    add_column :user_time_checks, :comments, :string
  end
end