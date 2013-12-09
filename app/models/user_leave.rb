class UserLeave < ActiveRecord::Base
  unloadable
  before_save :default_fractional_leave_value
  belongs_to :user
  
  validates :leave_date, :user_id, :leave_type, presence: true
  validates :leave_date, uniqueness: {scope: :user_id, message: 'has already been marked for the user'}
  validate :fractional_leave_correctness 
  
  def default_fractional_leave_value
    self.fractional_leave ||= 1
  end
  private :default_fractional_leave_value
  
  def fractional_leave_correctness
    if fractional_leave
      unless (fractional_leave <= 1)
        errors.add(:fractional_value,": Fractional Leave value can't be grater than 1")
      end
      unless (fractional_leave > 0)
        errors.add(:fractional_value,": Fractional Leave value can't be less than 0")
      end
    end
  end
  private :fractional_leave_correctness
end
