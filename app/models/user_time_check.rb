class UserTimeCheck < ActiveRecord::Base
  unloadable
  
  include Redmine::Utils::DateCalculation
  
  belongs_to :user
  
  validates :time_spent, :check_in_time, :check_out_time, presence: true, on: :update
  validate :correctness_of_user_time_checks
  
  class << self
    def checked_in?(user_id)
      exists?(['user_id = ? and check_out_time IS NULL', user_id])
    end
  end
  
  INDEX_ZK_NAME = 4
  INDEX_ZK_DATETIME = 1
  
  
  def self.as_csv
    
    CSV.generate do |csv|
      csv << ["USER ID", "User Name", "Check In Time", "Check Out Time ", "Time Spent", "Comments"] ## Header values of CSV
      all.each do |emp|
        csv << [emp.user_id, emp.user.name, emp.check_in_time, emp.check_in_time, emp.time_spent, emp.comments] ##Row values of CSV
      end
    end
  end


  def self.autogenerate_checkout(missed_checkout)
    if missed_checkout.check_in_time.hour < 16
      missed_checkout.update_attributes(check_out_time: missed_checkout.check_in_time + 6.hours, 
        comments: l(:auto_generated_comment),time_spent: 6*60)
    else
      #consider previously marked check_in_time as actually check_out time
      missed_checkout.update_attributes(check_in_time: missed_checkout.check_in_time - 6.hours, 
        check_out_time: missed_checkout.check_in_time,
        comments: l(:auto_generated_comment),time_spent: 6*60)

    end
  end
  
  def self.import(file, options = {:headers => false, :col_sep => "\t"} )
    unless file.nil?
      CSV.foreach(file.path, options) do |row|      
        name = row[INDEX_ZK_NAME]
        date = row[INDEX_ZK_DATETIME]
        first_last_name = name.split(" ")
        user = User.where(firstname: first_last_name.first, lastname: first_last_name.last).first
        logger.debug "#{name}#{date.to_datetime}#{user}"
        
        unless name && date && user
          # missing name or date or no records found in database
          next
        end
        
        #        date = "#{date} #{Time.zone}".to_datetime
        date=date.to_datetime
        missed_checkouts = UserTimeCheck.
          where(['user_id = ? AND check_in_time < ? AND check_out_time IS NULL', 
            user.id, date.beginning_of_day])
        missed_checkouts.each do |missed_checkout|
          autogenerate_checkout(missed_checkout)
        end
        
        checkin_timechecks = UserTimeCheck.
          where(['user_id = ? AND check_in_time < ? AND check_in_time > ? AND check_out_time IS NULL', 
            user.id, date.end_of_day, date.beginning_of_day])
        logger.debug checkin_timechecks
        if checkin_timechecks.empty?
          UserTimeCheck.create(user_id: user.id, check_in_time: date,check_out_time:  nil)
          logger.debug "#{'*'*50}#{user}#{'*'*50}"
        else
          user_time_check = checkin_timechecks.first
          checked_time = date.to_time - user_time_check.check_in_time.to_time
          difference = Time.at(checked_time).utc.strftime("%H").to_i
          if user_time_check.check_in_time.to_date == date.to_date
            if difference > 1 && difference < 16 
              #difference between first checkin and current pulled time is less than 16 and greater than 1 (meaning) not by mistake), so asssume checkout
              user_time_check.update_attributes(check_out_time: date,time_spent: checked_time/60)
              logger.debug '&'*50
            elsif difference > 16
              #difference between previous checkout and current is greater than 16, meaning that user missed out
              user_time_check.update_attributes(check_out_time: user_time_check.check_in_time + 6.hours, 
                comments: l(:auto_generated_comment),time_spent: 6*60)
              #   UserTimeCheck.create(user_id: user.id, check_in_time: date)
              logger.debug '$'*50

            else
              #ignore the check-in
            end
          elsif date.hour < 8 && difference > 1 && difference < 16
            #allow checkin/checkout for different days
            user_time_check.update_attributes(check_out_time: date,time_spent: checked_time/60)
          else
            #difference between previous checkout and current is greater than 16, meaning that user missed out
            autogenerate_checkout(user_time_check)
            UserTimeCheck.create(user_id: user.id, check_in_time: date)
            p '$'*50            
          end
        end        
      end
    end
  end
 
  
  def correctness_of_user_time_checks
    unless check_in_time.nil? || check_out_time.nil?
      if check_in_time > check_out_time
        errors.add(:check_in_time, ": cannot be greater than Check-Out Time")
      end   
    end
  end
  
  class << self
    def time_loggers_group
      Group.find(Setting.plugin_redmine_leaves['time_loggers_group'])
    end
    def time_log_receivers_group
      Group.find(Setting.plugin_redmine_leaves['time_log_receivers_group'])
    end
    def num_min_working_hours
      Setting.plugin_redmine_leaves['num_min_working_hours'].to_i || 8
    end
    
    def default_leave_type
      Setting.plugin_redmine_leaves['default_type'] || 'Annual'
    end
    
    def report_activity(report_days = 1, report_projects = true, 
        notify_missing_time = true, mark_leave_after_days = -1, error_tolerance = 0.25)
      projects = Project.active.includes(members: :user)    #get project timesheet
            
      start_date = Date.today - report_days.day
      end_date = Date.today - 1.day
      end_date = start_date if start_date > end_date

      return if working_days(start_date, end_date + 1.day) < 1
      
      users = User.in_group(time_loggers_group).where(status: User::STATUS_ACTIVE)
      
      
      email_group_timesheet(time_log_receivers_group, time_loggers_group, start_date, end_date) if report_projects
      
      email_project_timesheets(projects, start_date, end_date) if report_projects

      email_users_missing_hours(users, start_date, end_date) if notify_missing_time
      
      mark_leave_for_missing_hours(users, start_date, end_date, mark_leave_after_days, error_tolerance) if mark_leave_after_days > 0
    end

    def mark_leave_for_missing_hours(users, start_date, end_date, mark_leave_after_days, error_tolerance = 0.25)
      total_days = working_days(start_date, end_date)
      num_working_hours = total_days * num_min_working_hours

      start_date = start_date - mark_leave_after_days.days
      end_date = end_date - mark_leave_after_days.days
      
      user_ids = users.map(&:id)
      (start_date..end_date).each do |curr_date|
        num_working_hours = num_min_working_hours * (1 - error_tolerance)
        
        logged_time_user_ids = User.joins(:time_entries).where("#{TimeEntry.table_name}.spent_on" => curr_date, 
          "#{User.table_name}.id" => user_ids).ids
      
        missing_hours_users = TimeEntry.where(spent_on: curr_date, 
          user_id: logged_time_user_ids).group(:user_id).
          having("sum_hours < #{num_working_hours}").sum('hours')
              
        users_missing_time = User.where(id: missing_hours_users.keys)

        users_missing_time.each do |user|
          leave_day = calculate_leave_days(user, curr_date, curr_date)

          unless leave_day > 0
            leave_weight = (num_min_working_hours - missing_hours_user[user.id].to_f) / num_min_working_hours
            UserLeave.create!(user: user, leave_type: default_leave_type, comments: 'Missing time log', fractional_leave: leave_weight)
          end
        end
        
        no_hours_user_ids = user_ids - logged_time_user_ids
        users_no_time = User.where(id: no_hours_user_ids)
        users_no_time.each do |user|
          leave_days = calculate_leave_days(user, curr_date, curr_date)        
          unless leave_days > 0
            leave_weight = 1
            UserLeave.create!(user: user, leave_type: default_leave_type, comments: 'Missing time log', fractional_leave: leave_weight)
          end
        end        
      end      
    end
    
    def calculate_leave_days(user, start_date, end_date)
      leaves = user.user_leaves.where(leave_date: start_date..end_date)
      leaves.map do |leave| 
        leave.fractional_leave > 1 ? 1 : leave.fractional_leave
      end.reduce(:+).to_f      
    end
    private :calculate_leave_days
    
    
    def email_users_missing_hours(users, start_date, end_date)
      total_days = working_days(start_date, end_date)
      num_working_hours = total_days * num_min_working_hours
      user_ids = users.map(&:id)
      
      logged_time_user_ids = User.joins(:time_entries).where("#{TimeEntry.table_name}.spent_on" => start_date..end_date, 
        "#{User.table_name}.id" => user_ids).ids
      
      missing_hours_users = TimeEntry.where(spent_on: start_date..end_date, 
        user_id: logged_time_user_ids).group(:user_id).
        having("sum(hours) < ?", num_working_hours - 0.001).sum("hours")
      users_missing_time = User.where(id: missing_hours_users.keys)
      
      users_missing_time.each do |user|
        leave_days = calculate_leave_days(user, start_date, end_date)
        
        if leave_days > 0
          #recalculate missing hours for user
          num_working_hours = (total_days - leave_days) * num_min_working_hours
          
          #take into account leave time for user
          missing_hours_user = TimeEntry.where(spent_on: start_date..end_date, 
            user_id: user.id).group(:user_id).
            having("sum(hours) < ?", num_working_hours - 0.001).sum('hours')
          
          LeaveMailer.missing_time_log(user, start_date, end_date,
            missing_hours_user[user.id]).deliver if missing_hours_user[user.id]                   
        else
          LeaveMailer.missing_time_log(user, start_date, end_date,
            missing_hours_users[user.id]).deliver          
        end
      end
      
      no_hours_user_ids = user_ids - logged_time_user_ids
      users_no_time = User.where(id: no_hours_user_ids)
      users_no_time.each do |user|
        leave_days = calculate_leave_days(user, start_date, end_date)        
        if leave_days > 0
          #recalculate missing hours for user
          num_working_hours = (total_days - leave_days) * num_min_working_hours
          
          if num_working_hours > 0          
            LeaveMailer.missing_time_log(user, start_date, end_date, 0).deliver
          end
        else
          LeaveMailer.missing_time_log(user, start_date, end_date, 0).deliver          
        end
      end
    end

    def email_project_timesheets(projects, start_date, end_date)
      User.current.admin = true #set admin = true so that all time entries can be fetched
      for project in projects                     #get project Members for every project and send it to send_time_sheet_emial
        project_members = project.members
        for project_member in project_members
          email_project_timesheet(project_member.user, project_member.project,
            start_date, end_date) if project_member.roles.
            detect{|role|role.allowed_to?(:receive_timesheet_email)}
        end
      end
    end

    def email_project_timesheet(user, project, start_date, end_date)
      total_days = working_days(start_date, end_date)
      return if total_days < 1 
      #Make new object for time sheet get user ids form project and assign it to users

      billable_users_for_project = billable_users(project)
      time_entries_billable = TimeEntry.where(user_id: billable_users_for_project, 
        spent_on: start_date..end_date).
        includes(:activity, :project, :user)
      time_entries_users = {}
      time_entries_billable.each do |time_entry|
        time_entries_users[time_entry.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[time_entry.user][:time_entries] << time_entry
      end

      if time_entries_users.size < billable_users_for_project.size
        @@default_activity ||= TimeEntryActivity.first
        #put empty time entries for users who have not logged their time
        billable_users_for_project.each do |billable_user|
          time_entries_users[billable_user] ||= {
            time_entries: [build_empty_time_entry(billable_user, project, end_date)],
            user_leaves: []            
          }
        end
      end

      time_entries_other = TimeEntry.where("user_id NOT IN (?) and project_id = ? and spent_on >= ? and spent_on <= ?", 
        billable_users_for_project, project, start_date, end_date).
        includes(:activity, :project, :user)
      time_entries_other.each do |time_entry|
        time_entries_users[time_entry.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[time_entry.user][:time_entries] << time_entry
      end

      user_leaves = UserLeave.where(leave_date: start_date..end_date).includes(:user)
      user_leaves.each do |user_leave|
        time_entries_users[user_leave.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[user_leave.user][:user_leaves] << user_leave
        
      end
      
      timesheet_table = fetch_timesheet_table(time_entries_users)
      LeaveMailer.project_timesheet([user], timesheet_table, project.name, start_date, end_date).deliver
    end

    def email_group_timesheet(receiver_group, logger_group, start_date, end_date)
      #ignore project if no time is logged whatsoever
      total_days = working_days(start_date, end_date)
      return if total_days < 1
      
      receiver_users = User.in_group(receiver_group)
      users = User.in_group(logger_group)
      #Make new object for time sheet get user ids form project and assign it to users

      time_entries_billable = TimeEntry.where(user_id: users.map(&:id), 
        spent_on: start_date..end_date).
        includes(:activity, :project, :user)
      time_entries_users = {}
      time_entries_billable.each do |time_entry|
        time_entries_users[time_entry.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[time_entry.user][:time_entries] << time_entry
      end

      if time_entries_users.size < users.size
        @@default_activity ||= TimeEntryActivity.first
        #put empty time entries for users who have not logged their time
        users.each do |billable_user|
          time_entries_users[billable_user] ||= {
            time_entries: [build_empty_time_entry(billable_user, nil, end_date)],
            user_leaves: []
          }
        end
      end

      time_entries_other = TimeEntry.where("user_id NOT IN (?) and spent_on >= ? and spent_on <= ?", 
        users.map(&:id), start_date, end_date).
        includes(:activity, :project, :user)
      time_entries_other.each do |time_entry|
        time_entries_users[time_entry.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[time_entry.user][:time_entries] << time_entry
      end
      
      user_leaves = UserLeave.where(leave_date: start_date..end_date).includes(:user)
      user_leaves.each do |user_leave|
        time_entries_users[user_leave.user] ||= {time_entries: [], user_leaves: []}
        time_entries_users[user_leave.user][:user_leaves] << user_leave
        
      end
      
      timesheet_table = fetch_timesheet_table(time_entries_users)
      LeaveMailer.group_timesheet(receiver_users, timesheet_table, logger_group, start_date, end_date).deliver
    end
    
    def build_empty_time_entry(user_id, project, spent_on)
      @@default_activity ||= TimeEntryActivity.first
      time_entry = TimeEntry.new
      time_entry.user_id = user_id; time_entry.project = project
      time_entry.activity = @@default_activity; time_entry.hours = 0
      time_entry.spent_on = spent_on
      time_entry
    end
    private :build_empty_time_entry

    def billable_users(project)
      users = project.members.map(&:user)
      User.in_group(time_loggers_group).where(id: users.map(&:id))
    end
    private :billable_users
    
    def fetch_timesheet_table(time_entries_users)
      timesheet_table = []
      time_entries_users.each_pair do |user, time_leave_entries|
        time_entries = time_leave_entries[:time_entries]#: [], user_leaves: []}
        leaves = time_leave_entries[:user_leaves]#: [], user_leaves: []}
        project_total={}          #hash to get the project total against particular project
        user_project_activity_hours = {} #hash to build a particular model Users=>Projects=>activities=>issues
        for time_entry in time_entries
          project_total[time_entry.project_id] ||= 0
          project_total[time_entry.project_id] += time_entry.hours
          user_project_activity_hours[user] ||= {}
          activity_hours = user_project_activity_hours[user][time_entry.project] ||= {}

          activity_hours[time_entry.activity.name] ||= [[],0]
          activity_hours[time_entry.activity.name][0] << time_entry.issue
          activity_hours[time_entry.activity.name][1] += time_entry.hours
        end

        user_project_activity_hours.each_pair do |user, project_activity_hours|
          user_total = 0 #total time spent by user in all projects
          project_activity_hours.each_pair do |project, activity_hours|
            project_total = 0 #total time spent on project
            activity_hours.each_pair do |activity_name, issue_hours|
              timesheet_table << {user: user, project: project, activity: activity_name,
                issues: issue_hours[0], hours: issue_hours[1], total_heading: nil, total: nil}
              project_total += issue_hours[1]
            end
            timesheet_table << {user: nil, project: nil, activity: nil,
              issues: nil, hours: nil, total_heading: 'Project Total', total: project_total}
            user_total += project_total
          end
          timesheet_table << {user: nil, project: nil, activity: nil,
            issues: nil, hours: nil, total_heading: 'Total Leaves', 
            total: leaves.map(&:fractional_leave).reduce(&:+).to_f}
          timesheet_table << {user: nil, project: nil, activity: nil,
            issues: nil, hours: nil, total_heading: '<strong>User Total</strong>', total: user_total}
        end
      end

      timesheet_table
    end
    private :fetch_timesheet_table
  end
end
