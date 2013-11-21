class UserLeavesController < ApplicationController
  unloadable

  def new
    @user_leave = UserLeave.new
  end
  
  def create    
    #    @user_leave = UserLeave.create()
    selected_users = params['create_user_leave']['selected_users'] || ''
    selected_group_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => params['create_user_leave']['selected_groups'])
    
    selected_group_users.each do |user|
      selected_users << User.find(user).id
    end
    selected_users = selected_users.uniq
    puts selected_users

    #    if @user_leave.errors.empty?
    #      flash[:notice] = 'Leave Added!'
    #      redirect_to user_leave_reports_path
    #    else 
    #      render 'new'
    #    end
  end
  
  def edit
    @user_leave = UserLeave.find(params[:id])
  end
  
  def update    
    @user_leave = UserLeave.find(params[:id])
    if @user_leave.update_attributes(params[:user_leave])
      redirect_to user_leave_reports_path
    else
      render 'edit'
    end    
  end
    
  def destroy
    @user_leave = UserLeave.find(params[:id])
    @user_leave.destroy
    redirect_to user_leave_reports_path
  end
  
end
