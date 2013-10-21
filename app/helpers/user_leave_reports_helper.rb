module UserLeaveReportsHelper

  def plugin_setting(setting_name)
    (Setting.plugin_redmine_leaves[setting_name] || '').split(',')
  end

  def eligible_for_leave_users
    group_ids = Setting.plugin_redmine_leaves['eligible_for_leave_groups']
    User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => group_ids)
  end

  def user_options(selected_users)
    options_from_collection_for_select(eligible_for_leave_users, :id, :name, selected_users)
  end
  
  def leave_options(selected_leave_types)
    all_leave_types = plugin_setting('leave_types')
    options_for_select(all_leave_types, selected_leave_types)
  end
  
end
