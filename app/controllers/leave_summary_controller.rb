class LeaveSummaryController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def index
    @all_users = User.all
    @all_leaves = (Setting.plugin_redmine_leaves['leave_types']||"").split(",")
  end
  
  def report
  end

end

