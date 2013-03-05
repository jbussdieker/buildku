require 'buildku/project/base'
require 'buildku/project/make'
require 'buildku/project/gem'
require 'buildku/project/rails'

module Buildku
  module Project
    def self.build(name)
      base_project = Base.new(name)
      base_project._puts_masked "Starting Build"
      base_project.update_source
      type = base_project.detect_type
      if type != :base
        base_project._puts_masked "Detected #{type} project"
        project = Project.const_get(type.to_s.capitalize).new(name)
        project.build
      end
      base_project.deploy
    end
  end
end
