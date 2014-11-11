module UserTimeChecksHelper

  include TimelogHelper
  include ApplicationHelper
  include ActionView
  include Helpers
  include FormTagHelper
  
  def user_time_reporting
    if User.current.allowed_to_globally?(:view_time_reports,{})
      #      return deny_access
      return true
      
    else
#      return deny_access
      return false
    end
  end
  
    
  def edit_leave_options(user_leave_user_id)
    edit_leave_groups = Setting.plugin_redmine_leaves['edit_attendance']
    edit_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_leave_groups)
    
    edit_own_leave_groups ||= Setting.plugin_redmine_leaves['edit_own_attendance']
    edit_own_leave_users  ||= User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_own_leave_groups)
    
    is_current_user_in_edit_leave_users = edit_leave_users.include?(User.current)
    is_current_user_in_edit_own_leave_users = edit_own_leave_users.include?(User.current)
    
    if is_current_user_in_edit_leave_users
      return false if User.current.id == user_leave_user_id && !is_current_user_in_edit_own_leave_users
      return true
    else
      return true if User.current.id == user_leave_user_id && is_current_user_in_edit_own_leave_users
      return false
    end    
  end  

  
end
