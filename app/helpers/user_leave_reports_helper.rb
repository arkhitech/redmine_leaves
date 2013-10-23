module UserLeaveReportsHelper

  def mark_leave_users
    @mark_leave_users ||= begin
      mark_leave_groups = Setting.plugin_redmine_leaves['mark_leaves']
      if mark_leave_groups.present?
        User.active.joins(:groups).
          where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_leave_groups)
      else
        User.active.all
      end      
    end
  end
  
  def mark_own_leave_users
    @mark_own_leave_users ||= begin
      mark_own_leave_groups = Setting.plugin_redmine_leaves['mark_own_leave']
      User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => mark_own_leave_groups)
    end
  end
  
  def plugin_setting(setting_name)
    (Setting.plugin_redmine_leaves[setting_name] || '').split(',')
  end

  def eligible_for_leave_users
    group_ids = Setting.plugin_redmine_leaves['eligible_for_leave_groups']
    if group_ids.blank?
      User.active.all
    else
      User.active.joins(:groups).
      where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => 
        group_ids).group("#{User.table_name}.id")
    end
  end

  def user_options(selected_users)
    options_from_collection_for_select(eligible_for_leave_users, :id, :name, selected_users)
  end
  
  def leave_options(selected_leave_types)
    all_leave_types = plugin_setting('leave_types')
    options_for_select(all_leave_types, selected_leave_types)
  end
  
end
