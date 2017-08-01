module RedmineLeaves
  module Patches
    module UserPatch
      def self.included(base)
        
        base.class_eval do
          unloadable
          has_many :user_leaves, :foreign_key => 'user_id', :class_name => "UserLeave"
          has_many :user_time_checks, :foreign_key => 'user_id', :class_name => "UserTimeCheck"
          has_many :time_entries
        end
      end

    end
  end
end