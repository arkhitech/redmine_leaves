module UserTimeChecksHelper
  
  def edit_leave_options(user_leave_user_id)
    edit_leave_groups = Setting.plugin_redmine_leaves['edit_attendance']
    edit_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_leave_groups)
    
    edit_own_leave_groups = Setting.plugin_redmine_leaves['edit_own_attendance']
    edit_own_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_own_leave_groups)
    if(edit_leave_users.include?(User.current) && edit_own_leave_users.include?(User.current))
      # if current user have both permissions
      return true
    elsif(edit_leave_users.include?(User.current) && !edit_own_leave_users.include?(User.current))      
      # if current user have permission to mark leaves only
      if user_leave_user_id == User.current.id
        return false
      else
        return true
      end
    elsif(!edit_leave_users.include?(User.current) && edit_own_leave_users.include?(User.current))      
      # if current user have permission to mark own leaves
      if user_leave_user_id == User.current.id
        return true
      else
        return false
      end
    elsif(!edit_leave_users.include?(User.current) && !edit_own_leave_users.include?(User.current))
      return false
    end    
  end
  
end
