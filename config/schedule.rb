# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every :weekday, :at => '12pm' do
  rake "my_namespace:my_task1"
end
