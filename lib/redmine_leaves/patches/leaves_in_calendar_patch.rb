module RedmineLeaves
  module Patches
    module LeavesInCalendarPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end
      
      module InstanceMethods

        def events_with_leaves(project)
          @project=project
          @events_with_leaves ||= (self.events_with_leaves = @events)
        end
        
        def events_with_leaves_on(day,project)
          events_with_leaves(project)
          events_on(day)
        end
        
        def events_with_leaves=(events)
          leaves=[]
          if @project && @project.users 
            @project.users.each do |user| 
                leaves<<user.user_leaves.where(:leave_date => self.startdt..self.enddt)
            end
          end
          events += leaves.flatten
          @events = events
          @ending_events_by_days = @events.group_by {|event| (event.is_a? UserLeave) ? event.leave_date : event.due_date}
          @starting_events_by_days = @events.group_by {|event| (event.is_a? UserLeave) ? event.leave_date : event.due_date}
          @events
        end
        
      end
    end
  end
end