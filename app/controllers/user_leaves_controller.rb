class UserLeavesController < ApplicationController
  unloadable

  def new
    @leave = UserLeave.new
  end
  
  def create    
    
    if params['leave_date'] == ""
      flash[:error] = 'Please enter the Leave Date'
      redirect_to user_leave_reports_path
    else
      @leave = UserLeave.new(user_id: params['add_leave']['selected_user'], leave_type: params['add_leave']['selected_type'],
          leave_date: params['leave_date'].to_date)
      @leave.save
      flash[:notice] = 'Leave Added!'
      redirect_to user_leave_reports_path
    end
    
  end
  
  def edit
    @leave = UserLeave.find(params[:id])
  end
  
  def update
    
    @leave = UserLeave.find(params[:id])
    if @leave.update_attributes(user_id: params['add_leave']['selected_user'], leave_type: params['add_leave']['selected_type'],
          leave_date: params['leave_date'].to_date)
      redirect_to user_leave_reports_path
    else
      render 'edit'
    end
    
  end
    
  def destroy
    @delete = UserLeave.find(params[:id])
    @delete.destroy
    redirect_to user_leave_reports_path
  end
  
end
