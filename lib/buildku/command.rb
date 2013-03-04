module Buildku
  class Command
    def self.run(args)
      phase = args[0]
      command = args[1]

      if phase == "post-update"
        if command == "git-receive-pack"
          name = args[2]
          project = Project.new(name)
          project.build
        else
          #puts "Invalid command (#{command}) for phase #{phase}"
        end
      else
        #puts "Invalid command: (#{command}) for phase #{phase}"
      end
    end
  end
end
