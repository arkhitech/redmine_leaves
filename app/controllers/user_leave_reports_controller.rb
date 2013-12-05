class UserLeaveReportsController < ApplicationController
  unloadable
  
  before_filter :require_login

  include UserLeaveReportsHelper
    
  def index
#    init_group_users
    @all_users = User.all
    @all_leaves = plugin_setting('leave_types')
  end
  
  def report    
    #where_statements = []
    #where_clause = ['']
    @user_leaves = UserLeave
    
    unless params[:user_leave_report][:selected_users].nil?
      #where_statements << 'user_id IN (?)'
      #where_clause << params[:user_leave_report][:selected_users]
      @user_leaves.where(:user_id => params[:user_leave_report][:selected_users])
    end

    selected_leave_types = params[:user_leave_report][:selected_leave_types]
    unless selected_leave_types.nil?
      #where_statements << 'leave_type IN (?)'
      #where_clause << selected_leave_types
      @user_leaves.where(:leave_type => selected_leave_types)
    end

    unless params[:user_leave_report][:date_from].blank? 
#      where_statements << 'leave_date >= ?'
#      where_clause << params[:user_leave_report][:date_from]
      @user_leaves.where('leave_date >= ?', params[:user_leave_report][:date_from])
    end

    unless params[:user_leave_report][:date_to].blank?
#      where_statements << 'leave_date <= ?'
#      where_clause << params[:user_leave_report][:date_to]
      @user_leaves.where('leave_date <= ?', params[:user_leave_report][:date_to])
    end

    #where_clause[0] = where_statements.join(' AND ') 
    #@user_leaves = UserLeave.where(where_clause).order('leave_date desc')
    @user_leaves = @user_leaves.order('leave_date desc')
  
  end

end
