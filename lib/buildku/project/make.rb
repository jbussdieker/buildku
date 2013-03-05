module Buildku
  module Project
    class Make < Base
      def autoconfigure
        _puts_heading("Running autoconf")
        scroll_cmd("
  /bin/bash -c \"
  cd #{root_path}
  autoreconf -i
  \"
  ")
      end

      def configure
        _puts_heading("Running configure")
        scroll_cmd("
  /bin/bash -c \"
  cd #{root_path}
  ./configure
  \"
  ")
      end

      def make
        _puts_heading("Running make")
        scroll_cmd("
  /bin/bash -c \"
  cd #{root_path}
  make
  \"
  ")
      end

      def has_file? filename
        File.exists? File.join(root_path, filename)
      end

      def build
        autoconfigure unless has_file? "configure" or !(has_file? "configure.ac" or has_file? "configure.in")
        configure unless has_file? "Makefile" and !(has_file? "configure")
        make
      end
    end
  end
end
