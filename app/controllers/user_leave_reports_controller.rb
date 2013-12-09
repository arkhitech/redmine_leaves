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
    user_leaves = nil
    where_statements = []
    where_clause = ['']
    selected_groups=params[:user_leave_report][:selected_groups]
    unless (params[:user_leave_report][:selected_users].nil? && selected_groups.nil?)
      where_statements << 'user_id IN (?)'
      all_users=[]
      all_users << params[:user_leave_report][:selected_users]
      #end
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
      where_statements << 'leave_date >= ?'
      where_clause << params[:user_leave_report][:date_from]
    end

    unless params[:user_leave_report][:date_to].blank?
      where_statements << 'leave_date <= ?'
      where_clause << params[:user_leave_report][:date_to]
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
  end
end
