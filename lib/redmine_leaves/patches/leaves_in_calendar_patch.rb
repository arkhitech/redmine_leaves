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

        def events_with_leaves
          @events_with_leaves ||= (self.events_with_leaves = @events)
        end
        
        def events_with_leaves_on(day)
          events_with_leaves
          events_on(day)
        end
        
        def events_with_leaves=(events)
          events += UserLeave.where(:leave_date => self.startdt..self.enddt)
          @events = events
          @ending_events_by_days = @events.group_by {|event| (event.is_a? UserLeave) ? event.leave_date : event.due_date}
          @starting_events_by_days = @events.group_by {|event| (event.is_a? UserLeave) ? event.leave_date : event.due_date}
          @events
        end
        
      end
    end
  end
end