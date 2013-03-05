module Buildku
  module Project
    class Gem < Base
      def bundler
        unless File.exists? File.join(root_path, "Gemfile.lock")
          _puts_heading("Finding dependencies")
          scroll_cmd("
            /bin/bash -c \"
            source /usr/local/rvm/scripts/rvm
            cd #{root_path}
            bundle install
            \"
          ")
        end
        _puts_heading("Running bundle")
        scroll_cmd("
          /bin/bash -c \"
          source /usr/local/rvm/scripts/rvm
          cd #{root_path}
          bundle --deployment
          \"
        ")
      end

      def build
        bundler
      end
    end
  end
end

