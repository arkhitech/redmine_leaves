class UserLeave < ActiveRecord::Base
  unloadable
  belongs_to :user
  after_save :notify_the_absentee
  validates :leave_date, :user_id, :leave_type, presence: true
  validates :leave_date, uniqueness: {scope: :user_id, message: 'has already been marked for the user'}
  
    def notify_the_absentee
      LeaveMailer.notify_absentee(self).deliver
    end
  private :notify_the_absentee
end