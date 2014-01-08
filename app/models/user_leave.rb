class UserLeave < ActiveRecord::Base
  unloadable
  before_save :default_fractional_leave_value
  belongs_to :user
  
  validates :leave_date, :user_id, :leave_type, presence: true
  validates :leave_date, uniqueness: {scope: :user_id, message: 'has already been marked for the user'}
  validate :fractional_leave_correctness
  validate :uniqueness_and_returns_leave_type_of_existing_leave, :on => :create
  def notify_the_absentee
    LeaveMailer.notify_absentee(self).deliver
  end
  private :notify_the_absentee
  
  def default_fractional_leave_value
    self.fractional_leave ||= 1
  end
  private :default_fractional_leave_value
  
  def fractional_leave_correctness
    if fractional_leave
      unless (fractional_leave <= 1)
        errors.add(:fractional_value,l(:error_fractional_value_greater_than_one))
      end
      unless (fractional_leave > 0)
        errors.add(:fractional_value,l(:error_fractional_value_less_than_zero))
      end
    end
  end
  private :fractional_leave_correctness
  
  def uniqueness_and_returns_leave_type_of_existing_leave
    existing_leaves=UserLeave.where(leave_date: leave_date, user_id: user_id)
    unless existing_leaves.blank?
      errors.add(:leave_type,existing_leaves.first.leave_type)
    end
  end
  private :uniqueness_and_returns_leave_type_of_existing_leave
end
