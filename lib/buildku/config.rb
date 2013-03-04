require 'yaml'

module Buildku
  class Config
    attr_accessor :config

    def initialize(file)
      @config = YAML.load(File.open(file))
    end

    def merge!(opts)
      @config.merge! opts
    end

    def [](key)
      @config[key]
    end

    def method_missing(item, *args)
      @config[item] if @config.has_key? item
    end
  end

  def self.load_config
    ["/etc/buildku/settings.yml", "config/settings.yml"].each do |config_file|
      if File.exists? config_file
        return Config.new(config_file)
      end
    end

    raise "No config file detected."
  end

  def self.config
    @@config.dup
  end

  def self.configure(opts = {})
    @@config.merge! opts.dup
  end

  @@config = load_config
end

