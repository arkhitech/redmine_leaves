class CreateUserLeaves < ActiveRecord::Migration
  def change
    create_table :user_leaves do |t|
      t.integer :user_id, indexed: true
      t.string :leave_type
      t.date :leave_date
    end
  end
end
