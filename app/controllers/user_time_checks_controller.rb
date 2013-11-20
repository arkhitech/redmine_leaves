class UserTimeChecksController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def index
    @time_checks = UserTimeCheck.all
  end
  
  def edit
    @time_checks = UserTimeCheck.find(params[:id])
  end
  
  def update    
    @time_checks = UserTimeCheck.find(params[:id])
    if @time_checks.update_attributes(params[:user_time_check])
      redirect_to user_time_checks_path
    else
      render 'edit'
    end    
  end
  
  def check_in
    checkin_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])

    if checkin_timechecks.empty?
      @user_time_check = UserTimeCheck.create(user_id: User.current.id, check_in_time: DateTime.now)
    else
      flash.now[:error] = 'You did not check-out last time, please checkout first'
    end
  end
  
  def check_out
    checkout_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])
    
    if checkout_timechecks.empty?
      flash.now[:error] = 'You did not check-out last time, please checkout first'
    else
      @user_time_check = checkout_timechecks.first
      @user_time_check.update_attributes(check_out_time: DateTime.now)
    end
  end
  
end
