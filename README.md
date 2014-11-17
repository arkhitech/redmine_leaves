Redmine Leaves
==============

A simple plugin for user leaves management. It allows user to check-in and check-out for attendance marking. 
Leave is marked for any user that does not check-in by the specified time. 
Administrator can define leave types via the administrative interface for the plugin.

Users with permission 'eligible_for_leave' are shown in the list. 
A report summary page similar to the Timesheet Plugin shows the leaves summary. 
Leaves are also integrated into the Calendar Module. 
User who does not check-in, is automatically marked as off after some cut-off period Leave Types are defined through Redmine settings. 
User can also view the check-ins/check-outs and allowed users can edit attendance too.
Also, attendance can be imported in the form of csv files.
  
Installation:
-------------

- To install plugin, go to plugins folder of your Redmine repository and run:

        git clone http://github.com/arkhitech/redmine_leaves

- Run db migrations for the plugin

        rake redmine:plugins:migrate RAILS_ENV=production

- Run rake task to populate time_spent field in user_time_checks

        rake redmine_leaves:populate_time_spent

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

Snapshots:
-------------

![alt tag](http://arkhitech.com/sites/default/files/1-redmine_login.png)
![alt tag](http://arkhitech.com/sites/default/files/2-redmine_check-in.png)
![alt tag](http://arkhitech.com/sites/default/files/3-user_time_check_topmenu.png)
![alt tag](http://arkhitech.com/sites/default/files/4-browse_import_csv_file.png)
![alt tag](http://arkhitech.com/sites/default/files/5-edit-attendance.png)
![alt tag](http://arkhitech.com/sites/default/files/6-invalid_values_for_attendance_edit.png)
![alt tag](http://arkhitech.com/sites/default/files/7-attendance_time_value_%20updated.png)
![alt tag](http://arkhitech.com/sites/default/files/8-redmine_leaves_overview_sub_menu.png)
![alt tag](http://arkhitech.com/sites/default/files/9-redmine_leaves_summary_report.png)
![alt tag](http://arkhitech.com/sites/default/files/10.1-redmine_leaves_add_leave_submenu.png)
![alt tag](http://arkhitech.com/sites/default/files/10.2-redmine_leaves_leave_added_success.png)
![alt tag](http://arkhitech.com/sites/default/files/11-redmine_leaves_analytics_submenu.png)
![alt tag](http://arkhitech.com/sites/default/files/13-redmine_leaves_log_remaining_time.png)
![alt tag](http://arkhitech.com/sites/default/files/14-redmine_leaves_check_out_success.png)
![alt tag](http://arkhitech.com/sites/default/files/15-redmine_leaves_administration_plugins_redmine_leaves_configure.png)
![alt tag](http://arkhitech.com/sites/default/files/16-redmine_leaves_settings.png)
