module UserLeavesHelper
  
  def plugin_setting(setting_name)
    (Setting.plugin_redmine_leaves[setting_name] || '').split(',')
  end
  
  def add_user_options(selected_user)
    if(User.current.admin?)
      all_users = User.active
    else
      all_users = User.where(['id = ?', User.current.id]).active
    end
    options_from_collection_for_select(all_users, :id, :name, selected_user)
  end
  
  def add_leave_options(selected_leave_type)
    all_leave_types = plugin_setting('leave_types')
    options_for_select(all_leave_types, selected_leave_type)
  end
  
end
