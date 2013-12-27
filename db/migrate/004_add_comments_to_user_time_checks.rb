class AddCommentsToUserTimeChecks < ActiveRecord::Migration
  def change
    add_column :user_time_checks, :comments, :string
  end
end