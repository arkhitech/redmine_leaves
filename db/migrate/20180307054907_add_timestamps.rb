class AddTimestamps < ActiveRecord::Migration
  def change
    add_column :user_time_checks, :created_at, :datetime, null: false
    add_column :user_time_checks, :updated_at, :datetime, null: false

    add_column :user_leaves, :created_at, :datetime, null: false
    add_column :user_leaves, :updated_at, :datetime, null: false    
  end
end
