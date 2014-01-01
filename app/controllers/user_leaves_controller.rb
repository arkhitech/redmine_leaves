class UserLeavesController < ApplicationController
  unloadable

  def new
    @user_leave = UserLeave.new    
  end
  
  def create  
    errors = []
    selected_users = []
    if params['create_user_leave']['selected_users']
      selected_users = params['create_user_leave']['selected_users']
    end
    selected_group_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => params['create_user_leave']['selected_groups'])
    selected_date_from = params['create_user_leave']['selected_date_from'].map{|k,v| v}.join("-").to_date
    selected_date_to   = params['create_user_leave']['selected_date_to'].map{|k,v| v}.join("-").to_date    
    selected_group_users.each do |group_user|
      selected_users << User.find(group_user).id.to_s
    end
    unless selected_users.empty?
      selected_users = selected_users.uniq
      selected_users.each do |user|
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
        redirect_to new_user_leafe_path
      else
        flash[:notice] = 'Leave(s) Added!'
        redirect_to user_leave_reports_path
      end
    else
      flash[:error] = "No User/Group Selected!"
      redirect_to new_user_leafe_path
    end
  end
  
  def edit
    @user_leave = UserLeave.find(params[:id])
  end
  
  def update    
    @user_leave = UserLeave.find(params[:id])
    if @user_leave.update_attributes(params[:user_leave])
      redirect_to edit_user_leafe_path(@user_leave), notice: 'User Leave Updated!'
    else
      redirect_to edit_user_leafe_path(@user_leave), error: 'User Leave not Updated!'
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