class UserLeaveReportsController < ApplicationController
  unloadable
  
  before_filter :require_login

  include UserLeaveReportsHelper
  
  def index
    mark_leave_groups = Setting.plugin_redmine_leaves['mark_leaves']
    @mark_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_leave_groups)
    
    mark_own_leave_groups = Setting.plugin_redmine_leaves['mark_own_leave']
    @mark_own_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_own_leave_groups)

    @all_users = User.all
    @all_leaves = plugin_setting('leave_types')
  end
  
  def report    
    mark_leave_groups = Setting.plugin_redmine_leaves['mark_leaves']
    @mark_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_leave_groups)
    
    mark_own_leave_groups = Setting.plugin_redmine_leaves['mark_own_leave']
    @mark_own_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_own_leave_groups)

    @user_leaves = nil
    if params[:user_leave_report].nil?
      flash.now[:error] = 'Please provide a report criteria'
    else
      where_statements = []
      where_clause = ['']

      unless params[:user_leave_report][:selected_users].nil?
        where_statements << 'user_id IN (?)'
        where_clause << params[:user_leave_report][:selected_users]
      end

      selected_leave_types = params[:user_leave_report][:selected_leave_types]
      unless selected_leave_types.nil?
        where_statements << 'leave_type IN (?)'
        where_clause << selected_leave_types
      end

      unless params[:user_leave_report][:date_from].blank? 
        where_statements << 'leave_date >= ?'
        where_clause << params[:user_leave_report][:date_from]
      end
      
      unless params[:user_leave_report][:date_to].blank?
        where_statements << 'leave_date <= ?'
        where_clause << params[:user_leave_report][:date_to]
      end

      where_clause[0] = where_statements.join(' AND ') 
      @user_leaves = UserLeave.where(where_clause).order('leave_date desc')
    end
  
  end

end
