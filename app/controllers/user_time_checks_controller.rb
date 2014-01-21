class UserTimeChecksController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def index
    unless Redmine::Plugin.installed?(:redmine_wice_grid)
      flash.now[:warning] = "Please install Redmine 'WiceGrid' for better pagination"
      @time_checks = UserTimeCheck.includes(:user)
    else
      time_checks = UserTimeCheck.includes(:user)
      @time_checks = initialize_grid(time_checks)
    end       
  end
  
  def edit
    @time_checks = UserTimeCheck.find(params[:id])
  end
  
  def update    
    @time_checks = UserTimeCheck.find(params[:id])
    if @time_checks.update_attributes(params[:user_time_check])
      redirect_to user_time_checks_path, notice: l(:notice_time_check_updated)
    else
      render 'edit'
    end    
  end
  
  def import
    begin
      UserTimeCheck.import(params[:file])
      redirect_to user_time_checks_path, notice: l(:notice_time_check_file_imported) if params[:file]
    rescue StandardError => e
      redirect_to user_time_checks_path, :flash => { :error => l(:error_invalid_file_format) }
    end    
  end
  
  def check_in
    checkin_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])

    if checkin_timechecks.empty?
      @user_time_check = UserTimeCheck.create(user_id: User.current.id, check_in_time: DateTime.now)
    else
      flash.now[:error] = l(:error_checkout_first)
      @user_time_check = checkin_timechecks.first
    end
  end
  
  def check_out
    checkout_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])
    
    if checkout_timechecks.empty?
      flash.now[:error] = l(:error_checkin_first)
      @user_time_check = UserTimeCheck.new(:user_id => User.current.id)

    else
      @user_time_check = checkout_timechecks.first
      @user_time_check.update_attributes(check_out_time: DateTime.now)
      
      
      @time_entries= TimeEntry.where(user_id: User.current.id , created_on: (@user_time_check.check_in_time)..@user_time_check.check_out_time, spent_on: [@user_time_check.check_in_time.to_date,@user_time_check.check_out_time.to_date])
  
      #@new_time_entry=TimeEntry.new
       logged_in_time= @time_entries.sum(:hours)
         checked_time = @user_time_check.check_out_time - @user_time_check.check_in_time
         
      if logged_in_time<0.9*(checked_time/3600)
         flash.now[:error] = l(:error_less_time_logged)
          #@assigned_issues= Issue.where(assigned_to_id: User.current.id)
          @assigned_issues= Issue.where(assigned_to_id: User.current.id).joins(:status).
                             where("#{IssueStatus.table_name}.is_closed" => false)
         
         #@new_time_entries = Array.new(3) { assigned_issue.time_entries.build }
         @new_time_entries = []
         @assigned_issues.each do |assigned_issue|
          #@new_time_entries << TimeEntry.new(:issue_id => assigned_issue.id)
          @new_time_entries << assigned_issue.time_entries.build
         end
    end
    end
  end
  
  def create_time_entries
    logger.debug "#{'*'*80}\nReceived parameters: #{params.inspect}\n#{'*'*80}"
    #"time_entries"=>{"issue_id"=>["1", "2"], "hours"=>["1", "2"], "activity_id"=>["8", "8"], "comments"=>["asim", "hello"]}
    @new_time_entries = []
#    issue_ids = params[:issue_id]
#    issue_ids.each_index do |idx|
#      time_entries << TimeEntry.create(:issue_id => issue_ids[idx], :hours => params[:hours][idx])
#    end

    time_entry_paramss = params[:time_entries] || []
    time_entry_paramss.each do |time_entry_params|
      time_entry_this = TimeEntry.new(time_entry_params) #  This solves the .permit problem : See Model <user_id: protected>
      time_entry_this.user_id = User.current.id
      time_entry_this.save  
      @new_time_entries << time_entry_this
    end
         #@assigned_issues= Issue.where(assigned_to_id: User.current.id)
         @assigned_issues= Issue.where(assigned_to_id: User.current.id).joins(:status).
                             where("#{IssueStatus.table_name}.is_closed" => false)
         @user_time_check = UserTimeCheck.where(["user_id = ? and check_out_time IS NOT NULL", User.current.id]).limit(1).order('id DESC').first
        # @time_entries= TimeEntry.where(user_id: User.current.id , spent_on: (@user_time_check.check_in_time)..@user_time_check.check_out_time)
        @time_entries= TimeEntry.where(user_id: User.current.id , created_on: (@user_time_check.check_in_time)..@user_time_check.check_out_time+1.hour, spent_on: [@user_time_check.check_in_time.to_date,@user_time_check.check_out_time.to_date])
   
         logged_time= @time_entries.sum(:hours)
         checked_time = @user_time_check.check_out_time - @user_time_check.check_in_time
         
         if logged_time<0.90*(checked_time/3600) #may changed this
           render 'check_out'
         else
           render 'checkout_timelog_success'
         end
         
    
  end
  
 
  
end
