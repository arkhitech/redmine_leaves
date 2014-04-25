class UserLeavesController < ApplicationController
  unloadable
  
  include UserLeaveReportsHelper
  include UserLeavesHelper

  def new
    if !(!mark_leave_users.include?(User.current) && !mark_own_leave_users.include?(User.current))
      @user_leave = UserLeave.new
    else
      return deny_access
    end        
  end
  
  def create  
    errors = []
    selected_users = []
    invalid_group = false
    if params['create_user_leave']['selected_users']
      selected_users = params['create_user_leave']['selected_users']
    end
    selected_group_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => params['create_user_leave']['selected_groups'])
    if params['create_user_leave']['selected_date_from'].blank? || 
        params['create_user_leave']['selected_date_to'].blank?
      errors << "Date Field(s) cannot be empty!"
    else
      begin
        selected_date_from = params['create_user_leave']['selected_date_from'].to_date#.map{|k,v| v}.join("-").to_date
        selected_date_to   = params['create_user_leave']['selected_date_to'].to_date#.map{|k,v| v}.join("-").to_date    
      rescue
        errors << "Invalid Date Format!"
      end
    end
    selected_group_users.each do |group_user|
      selected_users << User.find(group_user).id.to_s
    end
    if selected_users.count == 1
      invalid_group = true
    end
    selected_users = check_selected_users(selected_users)
    puts selected_users.count
    unless selected_users.empty?
      selected_users = selected_users.uniq
      selected_users.each do |user|
        break unless errors.empty?
        leave_date = selected_date_from
        while leave_date <= selected_date_to
          @user_leave = UserLeave.new(user_id: user.to_i, leave_type: params['create_user_leave']['selected_leave'],
            leave_date: leave_date, comments: params['create_user_leave']['comments'], 
            fractional_leave: params['create_user_leave']['fractional_leave'])
          leave_date += 1
          unless @user_leave.save
            errors << "Leave for #{@user_leave.user.name} already exists as #{
            (@user_leave.errors[:leave_type]).first} for #{@user_leave.leave_date}"
          end 
        end       
      end
      errors=errors.flatten.uniq
      unless errors.blank?
        flash[:error]="#{errors.join('<br/>')}"
        render 'new'
      else
        flash[:notice] = l(:notice_leaves_added)
        redirect_to user_leave_reports_path
      end
    else
      if invalid_group
        flash[:error] = l(:error_invalid_user_group_selected)
        render 'new'
      else
        flash[:error] = l(:error_no_user_group_selected)
        render 'new'
      end
    end
  end
  
  def edit
    @user_leave = UserLeave.find(params[:id])
  end
  
  def update    
    @user_leave = UserLeave.find(params[:id])
    if @user_leave.update_attributes(params[:user_leave])
      redirect_to edit_user_leafe_path(@user_leave), notice: l(:notice_leaves_updated)
    else
      redirect_to edit_user_leafe_path(@user_leave), error: l(:error_leaves_not_updated)
    end    
  end
    
  def destroy
    @user_leave = UserLeave.find(params[:id])
    @user_leave.destroy
    respond_to do |format|
      format.js {}
    end    
  end
end
