module UserLeaveAnalyticsHelper
  include UserLeaveReportsHelper
  
  def all_leave_types
    (Setting.plugin_redmine_leaves['leave_types'] || '').split(',').delete_if { |index| index.blank? }
  end
  
  def leaves_count_for(user, leave, start_date, end_date)
    UserLeave.where(user_id: user, leave_type: leave, leave_date: start_date..end_date).sum(:fractional_leave)
  end
  
  def populate_pie_chart_for_user(user, start_date, end_date)
    data=[]
    all_leave_types.each do |leave|
      data << [leave.strip.to_s,
        ((leaves_count_for(user, leave,start_date,end_date)*100)/UserLeave.where(user_id: user, leave_date: start_date..end_date).sum(:fractional_leave)).round(2)]
    end
    data
  end
  
  def group_leaves(leave, start_date, end_date)
    group_leave_count = []
    Group.all.each do |group|
      group_leave_count << UserLeave.
        where(leave_type: leave,user_id: group.users,leave_date: start_date..end_date).sum(:fractional_leave).round(2)
    end
    group_leave_count
  end
  
  def populate_pie_chart_for_group(start_date, end_date)
    data=[]
    all_group_leaves = 0
    Group.all.each do |group|
      all_group_leaves += UserLeave.where(user_id: group.users, leave_date: start_date..end_date).sum(:fractional_leave)
    end
    Group.all.each do |group|
      data << [group.name, ((UserLeave.where(user_id: group.users, leave_date: start_date..end_date)
            .sum(:fractional_leave)*100)/all_group_leaves).round(2)]
    end
    data
  end
  
end
