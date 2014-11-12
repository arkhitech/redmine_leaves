class UserTimeChecksController < ApplicationController
  unloadable
  
  #  before_filter :require_login, :authorize, :only => :index
  include SortHelper
  #  before_filter  :authorize, :only => :index
  helper :sort
  
  def index
  
    time_checks= UserTimeCheck.
      select("#{UserTimeCheck.table_name}.*,sum(#{TimeEntry.table_name}.hours ) as logged_hours").
      joins("LEFT JOIN #{TimeEntry.table_name} on DATE(check_in_time) <= spent_on AND DATE(check_out_time) >= spent_on").
      group("#{UserTimeCheck.table_name}.id")
    @time_check_grid = initialize_grid(time_checks,
      :name => 'time_checks_grid',
      conditions: ["check_in_time >  ?", Time.now - 6.months],
      :enable_export_to_csv => true,
      :csv_field_separator => ';',
      :csv_file_name => 'UserTimeChecks')#,
     
    export_grid_if_requested('time_checks_grid' => 'time_check_grid')
  
  end
  
 
  def user_time_activity_report
  
    
    @trackers=Tracker.all
    
    @time_checks_for_trackers = {}
    @users_with_logged_activities=User.
      select("Distinct #{User.table_name}.id as user_id,#{User.table_name}.firstname,#{User.table_name}.lastname")
    .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
    .where(" #{TimeEntry.table_name}.spent_on>=? and  #{TimeEntry.table_name}.spent_on<=?",params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today )
     
    @user_stats = {}
    
    @time_spent_on_tracker = {}
    @trackers.each do |tracker|
          
      @time_spent_on_tracker[tracker.name] = User.
        select("#{User.table_name}.lastname, #{User.table_name}.firstname, #{User.
        table_name}.id as user_id, #{Tracker.table_name}.id as tracker_id,#{Tracker.
        table_name}.name as tracker_name,count(#{Tracker.
        table_name}.name)as num_of_trackers,sum(#{TimeEntry.
        table_name}.hours ) as time_spent")
      .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
      .joins("INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id= #{TimeEntry.table_name}.issue_id")
      .joins("INNER JOIN #{Tracker.table_name} on #{Issue.table_name}.tracker_id= #{Tracker.table_name}.id")
      .group("#{Tracker.table_name}.id, #{User.table_name}.id")
      .order("#{Tracker.table_name}.id")
      .where("#{Tracker.table_name}.name=? AND #{TimeEntry.
        table_name}.spent_on>=? AND  #{TimeEntry.table_name}.spent_on<=?",
        tracker.name, params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today )
    end
    
    
    @trackers.each do |tracker|
      user_tracker_stats = User.
        select("#{User.table_name}.lastname, #{User.table_name}.firstname, #{User.
        table_name}.id as user_id, #{Tracker.table_name}.id as tracker_id,#{Tracker.
        table_name}.name as tracker_name,count(#{Tracker.
        table_name}.name)as num_of_trackers,sum(#{TimeEntry.table_name}.hours ) as time_spent")
      .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
      .joins("INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id= #{TimeEntry.table_name}.issue_id")
      .joins("INNER JOIN #{Tracker.table_name} on #{Issue.table_name}.tracker_id= #{Tracker.table_name}.id")
      .group("#{Tracker.table_name}.id, #{User.table_name}.id")
      .order("#{Tracker.table_name}.id")
      .where("#{Tracker.table_name}.name=? AND #{TimeEntry.
        table_name}.spent_on>=? AND  #{TimeEntry.table_name}.spent_on<=?",
        tracker.name, params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today )
      
      user_tracker_stats.each do |user_tracker_stat|
        @user_stats[user_tracker_stat.user_id] ||= {user: user_tracker_stat, trackers: {}}
        @user_stats[user_tracker_stat.user_id][:trackers][user_tracker_stat.tracker_name] = user_tracker_stat
      end
    end    
     
    missed_due_dates=User.
      select("#{User.table_name}.firstname,#{User.table_name}.id as user_id, count(#{Tracker.
      table_name}.id)as missed_dates")
    .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
    .joins("INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id= #{TimeEntry.table_name}.issue_id")
    .joins("INNER JOIN #{Tracker.table_name} on #{Issue.table_name}.tracker_id= #{Tracker.table_name}.id")      
    .group("#{User.table_name}.id,#{Issue.table_name}.id")
    .where(
      "#{Issue.table_name}.due_date< #{Issue.table_name}.closed_on 
        and #{Issue.table_name}.due_date is not NULL
        and  #{Issue.table_name }.due_date >=? 
        and  #{Issue.table_name }.due_date <=?",params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today )
    
    missed_due_dates.each do |missed_due_dates|
      @user_stats[missed_due_dates.user_id] ||= {user: missed_due_dates, trackers: {}}
      
      @user_stats[missed_due_dates.user_id][:missed_due_dates] = missed_due_dates
    end
  end
 

 
 
  def user_time_activity_report_monthly

    @trackers=Tracker.all
    @months_and_years=User.
      select("Distinct #{User.table_name}.id as user_id,month(#{TimeEntry.table_name}.spent_on) as month,year(#{TimeEntry.table_name}.spent_on) as year")
    .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
    .where(" #{TimeEntry.table_name}.spent_on>=? and  #{TimeEntry.table_name}.spent_on<=?",params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today )
    .order("user_id")
    count_users=0
    @months_and_years.each do |user|
      unless user.nil?
        count_users=count_users+1
      end
    end
    
    @time_spent_on_tracker = {}
    @missed_dates = {}
    @months_and_years.each do |user|   
      @trackers.each do |tracker|
          
        @time_spent_on_tracker[tracker.name+user.user_id.to_s+user.month.to_s+user.year.to_s] = User.
          select(" #{User.table_name}.firstname,year(#{TimeEntry.table_name}.spent_on)as year,month(#{TimeEntry.table_name}.spent_on) as month")
        .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
        .joins("INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id= #{TimeEntry.table_name}.issue_id")
        .joins("INNER JOIN #{Tracker.table_name} on #{Issue.table_name}.tracker_id= #{Tracker.table_name}.id")
        .group("#{Tracker.table_name}.id,#{User.table_name}.id,year(#{TimeEntry.table_name}.spent_on),month(#{TimeEntry.table_name}.spent_on)")
        .select("#{Tracker.table_name}.id as tracker_id,#{Tracker.table_name}.name as tracker_name,count(#{Tracker.table_name}.name)as num_of_trackers,sum(#{TimeEntry.table_name}.hours ) as time_spent")
        .order("year(#{TimeEntry.table_name}.spent_on),month(#{TimeEntry.table_name}.spent_on),#{Tracker.table_name}.id")
        .where("#{Tracker.table_name}.name=?
              and #{TimeEntry.table_name}.spent_on>=? 
              and  #{TimeEntry.table_name}.spent_on<=? 
              and month(#{TimeEntry.table_name}.spent_on)=? 
              and year(#{TimeEntry.table_name}.spent_on)=?
              and #{User.table_name}.id=?",tracker.name,params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today ,user.month,user.year,user.user_id)

     
      end
      
      @missed_dates[user.user_id.to_s+user.month.to_s+user.year.to_s]=User.
        select(" #{User.table_name}.firstname,
      year(#{TimeEntry.table_name}.spent_on)as year,
      month(#{TimeEntry.table_name}.spent_on) as month,
      count(#{Tracker.table_name}.id)as missed_dates")
      .joins("INNER JOIN #{TimeEntry.table_name} on #{User.table_name}.id= #{TimeEntry.table_name}.user_id")      
      .joins("INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id= #{TimeEntry.table_name}.issue_id")
      .joins("INNER JOIN #{Tracker.table_name} on #{Issue.table_name}.tracker_id= #{Tracker.table_name}.id")      
      .group("#{User.table_name}.id,
      #{Issue.table_name}.id,
      year(#{TimeEntry.table_name}.spent_on),
      month(#{TimeEntry.table_name}.spent_on)")
      .where("#{Issue.table_name}.due_date< #{Issue.table_name}.closed_on 
      and #{Issue.table_name}.due_date is not NULL 
    and #{TimeEntry.table_name}.spent_on>=? 
              and  #{TimeEntry.table_name}.spent_on<=? 
and month(#{TimeEntry.table_name}.spent_on)=? 
              and year(#{TimeEntry.table_name}.spent_on)=?
              and #{User.table_name}.id=?",params[:date_from]||Date.today - 1.month,params[:date_to]||Date.today ,user.month,user.year,user.user_id)
      .order("year(#{Issue.table_name}.start_date),month(#{Issue.table_name}.start_date)")
      
    end

    @trackers=Tracker.all
    
 


  end
 

 

  def user_time_reporting

    time_checks = UserTimeCheck.select("user_id, check_in_time,check_out_time, 
AVG(TIME_TO_SEC(check_in_time)) as avg_check_in_time,
 AVG(TIME_TO_SEC(check_out_time)) as avg_check_out_time, 
avg(time_spent) as average_time")
    .includes(:user)
    .group('user_id')
    .where("check_out_time IS NOT NULL")#
    
    @time_report_grid = initialize_grid(time_checks,
      :name => 'time_checks_grid',
      conditions: ["check_in_time >  ?", Time.now - 6.months],
      :enable_export_to_csv => true,
      :csv_field_separator => ';',
      :csv_file_name => 'UserTimeCustom')#,
     
    export_grid_if_requested('time_checks_grid' => 'time_report_grid')
      
    
  end
  

  
  
  def user_time_reporting_weekly
  
    time_checks = UserTimeCheck.select("check_in_time as weekdays,week(check_in_time) as week,year(check_in_time) as year,check_in_time,
check_out_time ,user_id,
 AVG(TIME_TO_SEC(check_in_time)) as avg_check_in_time,
 AVG(TIME_TO_SEC(check_out_time)) as avg_check_out_time, 
 sum(time_spent) as time_spent,avg(time_spent) as average_time").
      includes(:user).
      group('user_id,year(check_in_time),week(check_in_time)').        
      order('year(check_in_time),week(check_in_time)')#.includes(:user)
      
    @time_report_grid_weekly = initialize_grid(time_checks,
      :name => 'time_checks_grid',
      conditions: ["check_in_time >  ?", Time.now - 6.months],
      :enable_export_to_csv => true,
      :csv_field_separator => ';',
      :csv_file_name => 'UserTimeWeekly')#,
     
    export_grid_if_requested('time_checks_grid' => 'time_report_grid_weekly')
   
   
        
   
  end
  
   
   
  def user_time_reporting_monthly
 

    time_checks = UserTimeCheck.includes(:user)
    .select("check_in_time, check_out_time, user_id,
 AVG(TIME_TO_SEC(check_in_time)) as avg_check_in_time,
 AVG(TIME_TO_SEC(check_out_time)) as avg_check_out_time, 
sum(time_spent) as time_spent,avg(time_spent) as average_time")
    .group('user_id,year(check_in_time),month(check_in_time)') 
    .order('year(check_in_time),month(check_in_time),user_id')
    .where("check_out_time IS NOT NULL")  
    @time_report_grid_monthly = initialize_grid(time_checks,
      :name => 'time_checks_grid',
      :enable_export_to_csv => true,
      # conditions: ["check_in_time >  ?", Time.now - 12.months],
      :csv_field_separator => ';',
      :csv_file_name => 'UserTimeMonthly')#,
             
    export_grid_if_requested('time_checks_grid' => 'time_report_grid_monthly')
  
  end    
  
  
    
    

  def edit
    @time_checks = UserTimeCheck.find(params[:id])
  end
  
  def update    
    @time_checks = UserTimeCheck.find(params[:id])    
    if @time_checks.update_attributes(params[:user_time_check])
      redirect_to user_time_checks_path, 
        notice: "User Time Check for <strong>#{@time_checks.user.name}</strong> 
                 on <strong>#{@time_checks.check_in_time.to_date}</strong> Updated. 
                #{view_context.link_to l(:link_edit), edit_user_time_check_path(@time_checks)}".html_safe
    else
      redirect_to edit_user_time_check_path(@time_checks), :flash => { :error => "Invalid Input!" }
    end    
  end
  
  def import
    begin
      UserTimeCheck.import(params[:file])
      redirect_to user_time_checks_path, notice: l(:notice_time_check_file_imported) if params[:file]
    rescue StandardError => e
      puts "#{e.message}\n#{e.backtrace.join("\n")}"
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
