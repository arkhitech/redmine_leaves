class LeaveSummaryController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def index
    @all_users = User.all
    @all_leaves = (Setting.plugin_redmine_leaves['leave_types']||"").split(",")
  end
  
  def report
    @reported_user = nil
    if params[:report].nil?
      flash.now[:error] = 'Please select user(s) / leave type(s)'
    else
      if params[:report][:selected_users] == nil
        selected_users = nil
      else
        selected_users = User.find(params[:report][:selected_users])
      end

      selected_leave_types = params[:report][:selected_leave_types]

      if(selected_users == nil || selected_leave_types == nil)
        flash.now[:error] = 'Please select user(s) / leave type(s)'
      else
        if params[:entered_date][:date_from].blank? || params[:entered_date][:date_from].blank?
          @reported_user = UserLeave.
                where(['user_id IN (?) AND leave_type IN (?)',
                selected_users, selected_leave_types])
        else
          @reported_user = UserLeave.
                where(['user_id IN (?) AND leave_type IN (?) AND leave_date <= ? AND leave_date >= ?',
                selected_users, selected_leave_types,
                params['entered_date']['date_to'].to_date, params['entered_date']['date_from'].to_date])
        end
      end
    end
  end

end

