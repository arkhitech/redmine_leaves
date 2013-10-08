every :weekday, :at => '12:01 pm' do
  rake "redmine_leaves:auto_leave_mark"
end
