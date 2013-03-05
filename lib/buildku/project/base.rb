require 'fileutils'

module Buildku
  module Project
    class Base
      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def config
        Buildku.config
      end

      def base_path
        File.expand_path(File.join(config.build_dir)) #, name))
      end

      def root_path
        File.expand_path(File.join(config.build_dir, name)) #, $$.to_s))
      end

      def tmp_slug
        File.expand_path(File.join(config.tmp_dir, name + ".tar.gz")) #, $$.to_s))
      end

      def simple_scroll_cmd(cmd)
        job = IO.popen(cmd)
        while rawline = job.gets
          rawline.split("\n").each do |line|
            line.strip!
            line = "   | \033[0;33m#{line[0..80]}\033[0m"
            _puts_masked line
          end
        end
        line = "   | \033[0;32mDone\033[0m"
        _puts_masked line
      end

      def scroll_cmd(cmd)
        job = IO.popen(cmd)
        lsize = 80
        empty_lines = true # in case of no output
        while rawline = job.gets
          rawline.split("\n").each do |line|
            _clear_line(lsize)

            line.strip!
            line = "   | \033[0;33m#{line[0..80]}\033[0m"
            lsize = line.length

            print line
            empty_lines = false
          end
        end
        unless empty_lines
          puts
          line = "   | \033[0;32mDone\033[0m"
          _puts_masked line
        end
      end

      def _clear_line(size)
        print "\b" * size
        print " " * size
        print "\b" * size
      end

      def _puts_masked(msg = "")
        puts "\b\b\b\b\b\b\b\b#{msg}"
      end

      def _puts_heading(name)
        _puts_masked " * \033[0;32m#{name}\033[0m..."
      end

      def update_source
        if File.exists? root_path
          _puts_heading("Updating project")
          scroll_cmd("cd #{root_path}; git pull 2>&1")
        else
          _puts_heading("Creating project")
          scroll_cmd("cd #{base_path}; git clone #{config.prefix}#{name} 2>&1")
        end
      end

      def detect_type
        if File.exists? File.join(root_path, "script", "rails")
          return :rails
        elsif File.exists? File.join(root_path, "configure.ac")
          return :make
        elsif File.exists? File.join(root_path, "configure")
          return :make
        elsif File.exists? File.join(root_path, "Makefile")
          return :make
        elsif File.exists? File.join(root_path, "Gemfile")
          return :gem
        else
          return :base
        end
      end

      def make_slug
        _puts_heading("Building slug")
        scroll_cmd("
  /bin/bash -c \"
  source /usr/local/rvm/scripts/rvm
  cd #{root_path}
  rm -f #{tmp_slug}
  tar -zcvf #{tmp_slug} . -C #{base_path} 2>&1
  \"
  ")
        _puts_masked("Slug size: " + `ls -lah #{tmp_slug} | awk '{print $5}'`)
      end

      def deploy
        make_slug
      end
    end
  end
end
