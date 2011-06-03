module ProjectRole
  module Patches
    module RolePatch
      def self.included(base)
        base.extend ClassMethods

        base.class_eval do
          unloadable
          belongs_to :project

          #TODO find a better way to resolve unique name validation issue
          def before_validation
            self.name = (self.name + self.project_id.to_i.to_s)
          end

          def after_validation
            self.name = self.name.gsub(/#{self.project_id.to_i}$/, '')
          end
        end
      end

      module ClassMethods
        # Define class methods here.
        # Find all the roles that can be given to a project member
        def get_by_project(aProjectId)
          find(:all, :conditions => {:builtin => 0, :project_id => aProjectId}, :order => 'position')
        end

        def name()
          if project
            super
          else
            super + '(' + l('label_global') + ')'
          end
        end

        def clone_role_to(aProject)
          find(:all, :conditions => {:project_id => nil}, :order => 'position').each do |role|
            r = role.clone
            r.project_id = aProject.id
            r.save(false) #skip name validation for clone
            Workflow.copy(nil, role, nil, r)
          end
        end
      end
    end
  end
end
