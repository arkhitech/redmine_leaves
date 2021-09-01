class UserLeaveReportsController < ApplicationController
  unloadable
  
  before_action :require_login

  include UserLeaveReportsHelper
  
  def index
    @all_users = User.all
    @all_leaves = plugin_setting('leave_types')
  end
  
  def report  
    if params[:user_leave_report].nil?
      flash.now[:error] = t(:error_no_params )
      return
    end
    
    user_leaves = nil
    where_statements = []
    where_clause = ['']
    selected_groups = params[:user_leave_report][:selected_groups]

    unless (params[:user_leave_report][:selected_users].nil? && selected_groups.nil?)
      where_statements << 'user_id IN (?)'
      all_users=[]
      all_users << params[:user_leave_report][:selected_users]

      unless selected_groups.nil?
        selected_groups.each do |selected_group|
          group=Group.where(lastname: selected_group)
          all_users << group.first.users unless group.first.users.nil?
        end
      end
      where_clause << all_users.flatten.uniq
    end

    selected_leave_types = params[:user_leave_report][:selected_leave_types]
    unless selected_leave_types.nil?
      where_statements << 'leave_type IN (?)'
      where_clause << selected_leave_types
    end

    unless params[:user_leave_report][:date_from].blank? 
      begin
        where_statements << 'leave_date >= ?'
        where_clause << params[:user_leave_report][:date_from].to_date
      rescue StandardError
        flash.now[:error] = t(:error_invalid_date)
        return
      end
    end

    unless params[:user_leave_report][:date_to].blank?
      begin
        where_statements << 'leave_date <= ?'
        where_clause << params[:user_leave_report][:date_to].to_date
      rescue StandardError
        flash.now[:error] = t(:error_invalid_date)
        return
      end
    end
    
    where_clause[0] = where_statements.join(' AND ') 
    @user_leave = UserLeave.where(where_clause).order('leave_date desc')

  if @user_leave .nil? || @user_leave .empty?
      flash.now[:error] = t(:error_no_results)
  end
      
    @leaves_report_grid = initialize_grid(@user_leave.order(id: :desc),
      name: 'grid',
      enable_export_to_csv: true,
      csv_field_separator: ';',
      csv_file_name: 'LeavesReport')
 
    export_grid_if_requested('grid' => 'grid')
    
    
    
    
  end
end
