module Buildku
  class Command
    def self.run(args)
      phase = args[0]
      command = args[1]
      $stdout.sync = true

      if phase == "post-update"
        if command == "git-receive-pack"
          name = args[2]
          Project.build(name)
        else
          #puts "Invalid command (#{command}) for phase #{phase}"
        end
      else
        #puts "Invalid command: (#{command}) for phase #{phase}"
      end
    end
  end
end
