class UserLeave < ActiveRecord::Base
  unloadable
  belongs_to :user
  
  validates :leave_date, :user_id, :leave_type, presence: true
  validates :leave_date, uniqueness: {scope: :user_id, message: 'has already been marked for the user'}

end
