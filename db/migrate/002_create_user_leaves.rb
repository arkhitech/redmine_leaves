class CreateUserLeaves < ActiveRecord::Migration[4.2]
  def change
    create_table :user_leaves do |t|
      t.integer :user_id, indexed: true
      t.string :leave_type
      t.date :leave_date
    end
  end
end
