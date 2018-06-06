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

  def user_allowed_to_edit_leaves?
    User.current.admin? || edit_attendance_users.include?(User.current) || edit_own_attendance_users.include?(User.current)    
  end
  
  def user_allowed_to_edit_leave?(user_leave)
    return true if User.current.admin?
    return true if user_leave.user != User.current && edit_attendance_users.include?(User.current)
    return true if user_leave.user == User.current && edit_own_attendance_users.include?(User.current)    
    #else
    false
  end
  def edit_attendance_users
    @edit_attendance_users ||= begin
      edit_attendance_groups = Setting.plugin_redmine_leaves['edit_attendance']
      User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_attendance_groups)
    end
  end
  def edit_own_attendance_users
    @edit_own_attendance_users ||= begin
      edit_own_attendance_groups = Setting.plugin_redmine_leaves['edit_own_attendance']
      User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => edit_own_attendance_groups)
    end
  end  
  def plugin_setting(setting_name)
    (Setting.plugin_redmine_leaves[setting_name] || '').split(',').delete_if { |index| index.blank? }
  end

  def eligible_for_leave_users
    group_ids = Setting.plugin_redmine_leaves['eligible_for_leave_groups']
    if group_ids.blank?
      time_loggers_group = Group.find(Setting.plugin_redmine_leaves['time_loggers_group'])
      @eligible_users = User.in_group(time_loggers_group)
#     @eligible_users.order('users.name ASC').all.map{ |c| [c.name, c.id] }
      @eligible_users.sort_by{|e| e[:firstname]}
    else
      @eligible_users= User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => 
          group_ids).group("#{User.table_name}.id")
      @eligible_users.sort_by{|e| e[:firstname]}
      
      end
    end

    def user_options(selected_users)
      options_from_collection_for_select(eligible_for_leave_users, :id, :name, selected_users)
    end
  
    def leave_options(selected_leave_types)
      all_leave_types = plugin_setting('leave_types')
      options_for_select(all_leave_types, selected_leave_types)
    end
  
    def group_options(selected_groups)
      all_group_types = Group.all
      options_for_select(all_group_types, selected_groups)
    end
    def group_by_options(selected_group_by)
      group_by = [[t(:options_group_by_title ),'Leave type'],
        [t(:option_group_by_user),'User'],
        [t(:option_group_by_date),'Date']]
      options_for_select(group_by, selected_group_by)
    end
  
  end
