module Buildku
  module Project
    class Rails < Gem
      def write_db
        _puts_heading("Writing database.yml")
        db_prefix = name.gsub("-", "_")
        File.open(File.join(root_path, "config", "database.yml"), 'w') do |f|
          f.puts "development:"
          f.puts "  adapter: mysql2"
          f.puts "  host: #{config.db_host}"
          f.puts "  username: #{config.db_username}"
          f.puts "  password: #{config.db_password}"
          f.puts "  database: #{db_prefix}_development"
          f.puts "production:"
          f.puts "  adapter: mysql2"
          f.puts "  host: #{config.db_host}"
          f.puts "  username: #{config.db_username}"
          f.puts "  password: #{config.db_password}"
          f.puts "  database: #{db_prefix}_production"
          f.puts "test:"
          f.puts "  adapter: mysql2"
          f.puts "  host: #{config.db_host}"
          f.puts "  username: #{config.db_username}"
          f.puts "  password: #{config.db_password}"
          f.puts "  database: #{db_prefix}_test"
        end
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
        super
        write_db
        compile_assets
      end
    end
  end
end
