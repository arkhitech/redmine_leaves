class UserLeaveReportsController < ApplicationController
  unloadable
  before_filter :find_optional_project
  before_filter :require_login

  include UserLeaveReportsHelper
  
  def index
    
    @all_leaves = plugin_setting('leave_types')
  end
  
  def project_index
    @project = Project.find(params[:project_id])
    @all_project_users = @project.users
    @all_leaves = plugin_setting('leave_types')
    render 'project_leaves_index'
  end
  
  
  def generate_report  
    if params[:user_leave_report].nil?
      flash.now[:error] = l(:error_no_params )
      return
    end
    
    user_leaves = nil
    where_statements = []
    where_clause = ['']
    selected_groups=params[:user_leave_report][:selected_groups]

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
        flash.now[:error] = l(:error_invalid_date)
        return
      end
    end

    unless params[:user_leave_report][:date_to].blank?
      begin
        where_statements << 'leave_date <= ?'
        where_clause << params[:user_leave_report][:date_to].to_date
      rescue StandardError
        flash.now[:error] = l(:error_invalid_date)
        return
      end
    end
    
    where_clause[0] = where_statements.join(' AND ') 
    user_leaves = UserLeave.where(where_clause).order('leave_date desc')

    @divided_leaves={}
    case params[:user_leave_report][:selected_group_by]
    when 'User'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.user.name.to_sym]
          @divided_leaves[user_leave.user.name.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.user.name.to_sym]=[]
          @divided_leaves[user_leave.user.name.to_sym]<<user_leave
        end
      end
    when 'Leave type'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.leave_type.to_sym]
          @divided_leaves[user_leave.leave_type.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.leave_type.to_sym]=[]
          @divided_leaves[user_leave.leave_type.to_sym]<<user_leave
        end
      end
    when 'Date'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.leave_date.to_s.to_sym]
          @divided_leaves[user_leave.leave_date.to_s.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.leave_date.to_s.to_sym]=[]
          @divided_leaves[user_leave.leave_date.to_s.to_sym]<<user_leave
        end
      end
    end
    
    if @divided_leaves.nil? || @divided_leaves.empty?
      flash.now[:error] = l(:error_no_results)
      if params[:user_leave_report][:date_from].present? && params[:user_leave_report][:date_to].present?
        if params[:user_leave_report][:date_from] > params[:user_leave_report][:date_to]
          flash.now[:error]=l(:error_from_greater_than_to)
        else
          flash.now[:error] = l(:error_no_results)
        end        
      end
    end
  end
  
  
  def project_report  
    if params[:user_leave_report].nil?
      flash.now[:error] = l(:error_no_params )
      return
    end
    
    project = Project.find(params[:project_id])
    @all_project_users = project.users
    user_leaves = nil
    where_statements = []
    where_clause = ['']
    selected_groups=params[:user_leave_report][:selected_groups]

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
        flash.now[:error] = l(:error_invalid_date)
        return
      end
    end

    unless params[:user_leave_report][:date_to].blank?
      begin
        where_statements << 'leave_date <= ?'
        where_clause << params[:user_leave_report][:date_to].to_date
      rescue StandardError
        flash.now[:error] = l(:error_invalid_date)
        return
      end
    end
    
    where_clause[0] = where_statements.join(' AND ') 
    user_leaves = UserLeave.where(where_clause).order('leave_date desc')

    @divided_leaves={}
    case params[:user_leave_report][:selected_group_by]
    when 'User'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.user.name.to_sym]
          @divided_leaves[user_leave.user.name.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.user.name.to_sym]=[]
          @divided_leaves[user_leave.user.name.to_sym]<<user_leave
        end
      end
    when 'Leave type'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.leave_type.to_sym]
          @divided_leaves[user_leave.leave_type.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.leave_type.to_sym]=[]
          @divided_leaves[user_leave.leave_type.to_sym]<<user_leave
        end
      end
    when 'Date'
      user_leaves.each do |user_leave|
        if @divided_leaves[user_leave.leave_date.to_s.to_sym]
          @divided_leaves[user_leave.leave_date.to_s.to_sym]<<user_leave
        else
          @divided_leaves[user_leave.leave_date.to_s.to_sym]=[]
          @divided_leaves[user_leave.leave_date.to_s.to_sym]<<user_leave
        end
      end
    end
    
    if @divided_leaves.nil? || @divided_leaves.empty?
      flash.now[:error] = l(:error_no_results)
      if params[:user_leave_report][:date_from].present? && params[:user_leave_report][:date_to].present?
        if params[:user_leave_report][:date_from] > params[:user_leave_report][:date_to]
          flash.now[:error]=l(:error_from_greater_than_to)
        else
          flash.now[:error] = l(:error_no_results)
        end        
      end
    end
    render 'project_report'
  end
  
  def find_optional_project
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
    allowed = User.current.allowed_to?({:controller => params[:controller], :action => params[:action]}, @project, :global => true)
    allowed ? true : deny_access
  rescue ActiveRecord::RecordNotFound
    render_404
  end  
  
end
