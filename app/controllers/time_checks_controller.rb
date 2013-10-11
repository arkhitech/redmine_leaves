class TimeChecksController < ApplicationController
  unloadable
  
  before_filter :require_login

  def index
#    a=Redmine::MenuManager::MenuItem.new(:time_checks,
#      { :controller => 'time_checks', :action => 'index' }, :caption => 'Check-in/Check-out')
#    a.caption()
  end
  
  def checkin
    checkin_timechecks = TimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])

    if checkin_timechecks.empty?
      @user_checkin = nil
    else
      @user_checkin = checkin_timechecks.first
    end
    
#    @c.each do |check|
      
#      if(check.check_in_time != nil  && check.check_out_time != nil )
#        #do nothing. trying to find record with empty field
#      else
#        @u = check
#        break
#      end
#    end
  end
  
  def checkout
    checkout_timechecks = TimeCheck.all
    @user_checkout = nil
    
    checkout_timechecks.each do |check|
      
      if(check.check_out_time == nil )
        @user_checkout = check
        break
      end
    end
  end
  
end
