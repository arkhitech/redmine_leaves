module RedmineLeaves
  module Patches
    module TimeRestrictionPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          validate :spent_on_log_time_restriction
        end

      end

      module ClassMethods
      end

      module InstanceMethods
        def spent_on_log_time_restriction
          unless User.current.admin
            errors.add(:spent_on, "can't be #{max_past_time_log_insert_days} days older in the past") if !spent_on.blank? && spent_on < (Date.today - max_past_time_log_insert_days.days)
            errors.add(:spent_on, "can't be in future") if !spent_on.blank? && spent_on > Date.today
          end
        end

        def max_past_time_log_insert_days
          (Setting.plugin_redmine_leaves['max_past_timelog_insert_days'] || 7).to_i
        end
        private :max_past_time_log_insert_days
      end
    end
  end
end
