require 'fileutils'

module Buildku
  class Project
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
      puts unless empty_lines
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

    def clone_source
      if File.exists? root_path
        _puts_heading("Updating project")
        scroll_cmd("cd #{root_path}; git pull 2>&1")
      else
        _puts_heading("Creating project")
        scroll_cmd("cd #{base_path}; git clone #{config.prefix}#{name} 2>&1")
      end
    end

    def write_db
      _puts_heading("Writing database.yml")
      File.open(File.join(root_path, "config", "database.yml"), 'w') do |f|
        f.puts "development:"
        f.puts "  adapter: mysql2"
        f.puts "  host: #{config.db_host}"
        f.puts "  username: #{config.db_username}"
        f.puts "  password: #{config.db_password}"
        f.puts "  database: #{name}_development"
        f.puts "production:"
        f.puts "  adapter: mysql2"
        f.puts "  host: #{config.db_host}"
        f.puts "  username: #{config.db_username}"
        f.puts "  password: #{config.db_password}"
        f.puts "  database: #{name}_production"
        f.puts "test:"
        f.puts "  adapter: mysql2"
        f.puts "  host: #{config.db_host}"
        f.puts "  username: #{config.db_username}"
        f.puts "  password: #{config.db_password}"
        f.puts "  database: #{name}_test"
      end
    end

    def install_gems
      _puts_heading("Installing gems")
      scroll_cmd("
/bin/bash -c \"
source /usr/local/rvm/scripts/rvm
cd #{root_path}
bundle --deployment
\"
")
    end

    def compile_assets
      _puts_heading("Compiling assets")
      scroll_cmd("
/bin/bash -c \"
source /usr/local/rvm/scripts/rvm
cd #{root_path}
bundle exec rake assets:precompile --trace 2>&1
\"
")
    end

    def build
      $stdout.sync = true

      _puts_masked
      _puts_masked("Building #{name}")
      clone_source
      write_db
      install_gems
      compile_assets
      _puts_masked("Done")
      _puts_masked

      #puts IO.popen("cd #{@@config[:build_dir]}/#{name}; unset BUNDLE_GEMFILE; unset RUBYOPT; bundle exec rake assets:precompile").readlines
    end
  end
end
