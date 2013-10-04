class LeaveSummaryController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def index
    @all_users = User.all
    @selected_user
    
    @all_leaves = Setting.plugin_tracker['leave_types'].split(",")
    @selected_leave
  end
  
  def show
  end

end
