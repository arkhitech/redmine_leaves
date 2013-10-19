class UserTimeCheck < ActiveRecord::Base
  unloadable
  class << self
    def checked_in?(user_id)
      exists?(['user_id = ? and check_out_time IS NULL', user_id])
    end
  end
end
