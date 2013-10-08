module LeaveSummaryHelper

  def user_options(selected_users)
    all_users = User.active
    options_from_collection_for_select(all_users, :id, :name, selected_users)
  end
  
  def leave_options(selected_leave_types)
    all_leave_types = (Setting.plugin_redmine_leaves['leave_types']||"").split(",")
    options_for_select(all_leave_types, selected_leave_types)
  end
  
end
