module UserLeavesHelper
  
  def plugin_setting(setting_name)
    (Setting.plugin_redmine_leaves[setting_name] || '').split(',')
  end
  
  def add_user_options(selected_user)    
    mark_leave_groups = Setting.plugin_redmine_leaves['mark_leaves']
    mark_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_leave_groups)
    
    mark_own_leave_groups = Setting.plugin_redmine_leaves['mark_own_leave']
    mark_own_leave_users = User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_own_leave_groups)
    
    if(mark_leave_users.include?(User.current) && mark_own_leave_users.include?(User.current))
      # if current user have both permissions
      all_users = User.active
    end
    if(mark_leave_users.include?(User.current) && !mark_own_leave_users.include?(User.current))      
      # if current user have permission to mark leaves only
      all_users = User.active - User.where(['id = ?', User.current.id])
    end
    if(!mark_leave_users.include?(User.current) && mark_own_leave_users.include?(User.current))      
      # if current user have permission to mark own leaves
      all_users = User.where(['id = ?', User.current.id]).active
    end
    
    options_from_collection_for_select(all_users, :id, :name, selected_user)
    
  end
  
  def add_leave_options(selected_leave_type)
    all_leave_types = plugin_setting('leave_types')
    options_for_select(all_leave_types, selected_leave_type)
  end
  
end
