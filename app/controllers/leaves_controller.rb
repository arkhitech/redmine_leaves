class LeavesController < ApplicationController
  unloadable

  def new
    @leave = UserLeave.new
  end
  
  def create    
    if params['leave_date'] == ""
      flash[:error] = 'Please enter the Leave Date'
      redirect_to new_leafe_path
    else
      UserLeave.create(user_id: params['add_leave']['selected_user'], leave_type: params['add_leave']['selected_type'],
          leave_date: params['leave_date'].to_date)
      flash[:notice] = 'Leave Added!'
      redirect_to new_leafe_path
    end
  end
    
  def destroy
    @delete = UserLeave.find(params[:id])
    @delete.destroy

    redirect_to leave_summary_index_path
  end
  
end
