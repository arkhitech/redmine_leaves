class TimechecksController < ApplicationController
  unloadable
  
  before_filter :require_login

  def index
#    puts settings['leave_types']
  end
  
  def checkin
    @c = TimeCheck.all
    @u = nil
    
    @c.each do |check|
      
      if(check.check_in_time != nil  && check.check_out_time != nil )
        #do nothing. trying to find record with empty field
      else
        @u = check
        break
      end
    end
  end
  
  def checkout
    @o = TimeCheck.all
    @out = nil
    
    @o.each do |check|
      
      if(check.check_out_time == nil )
        @out = check
        break
      end
    end
  end
  
end
