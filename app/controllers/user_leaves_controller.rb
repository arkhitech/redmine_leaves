class UserLeavesController < ApplicationController
  unloadable

  def new
    @user_leave = UserLeave.new    
  end
  
  def create  
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
          @user_leave = UserLeave.create(user_id: user.to_i, leave_type: params['create_user_leave']['selected_leave'],
            leave_date: leave_date, comments: params['create_user_leave']['comments'])
          leave_date += 1
        end        
      end
      flash[:notice] = 'Leave Added!'
      redirect_to user_leave_reports_path
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
