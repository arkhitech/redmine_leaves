module RedmineLeaves
  module Patches
    module UserPatch
      def self.included(base)
        
        base.class_eval do
          unloadable
          has_many :user_leaves
        end
      end

    end
  end
end