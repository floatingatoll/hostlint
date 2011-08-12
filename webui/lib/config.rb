require "rubygems"
require "models"
require "optparse"

module Dash
  class Config
    include Dash::Models
    attr_reader :global_config, :report_dir

    def initialize
      port = 9292
      @rawconfig = {}
      @conf_file = "./config.yml"

      optparse = OptionParser.new do |o|
        o.on("-f", "--config-file FILE",
          "location of the config directory (default .)") do |arg|
          @conf_file = arg
        end
        o.on("-p", "--port PORT", "port to bind to (default 9292)") do |arg|
          port = arg.to_i
        end
      end

      optparse.parse!
      reload!
      @global_config[:port] = port
    end

    def reload!
      @global_config = YAML.load(File.read(@conf_file))[:main]
      # do some sanity checking of other configuration parameters
      [:report_dir].each do |c|
        if not @global_config[c]
          raise "Missing config name '#{c.to_s}'"
        end
      end
      @report_dir = @global_config[:report_dir]
      puts 'done!'
    end
  end # Dash::Config
end # Dash
