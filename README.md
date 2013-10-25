Redmine Leaves
==============

A simple plugin for user leaves management. It allows user to check-in and check-out for attendance marking. Leave is marked for any user that does not check-in by the specified time. Administrator can define leave types via the administrative interface for the plugin

Only users with permission eligible_for_leave are shown in the list. A report summary page similar to the Timesheet Plugin shows the leaves summary. Leaves are also integrated into the Calendar Module (if possible). User who does not check-in, is automatically marked as off after some cut-off period Leave Types are defined through Redmine settings
  
Installation:
-------------

- To install plugin, go to plugins folder of your Redmine repository and run:

        git clone http://github.com/arkhitech/redmine_leaves

- Run db migrations for the plugin

        rake redmine:plugins:migrate RAILS_ENV=production

- Bundle install all the gems using the following command

        bundle install

- After bundle install, go to Redmine leave plugin folder and run the following command

        wheneverize .

- Above command creates a file “schedule.rb” in config folder. Go to config/schedule.rb and type the following code

        every :weekday, :at => '12:01 pm' do
            rake "redmine_leaves:auto_leave_mark"
        end

- Run the following command to automate the leave marking process

        whenever --update-crontab store

- After installation, log in to Redmine as administrator and go to plugin settings for Redmine leaves plugin configuration.

Instructions:
-------------

- After installing Redmine leave plugin, it is advised to make Redmine groups and add users into these groups. This will allow the admin to assign permissions to users accordingly.

- Admin will be required to always update the "Auto-Mark" process whenever the server restarts. To do so, go to congif/schedule.rb and run the following command

        whenever --update-crontab store