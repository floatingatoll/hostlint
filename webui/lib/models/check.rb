###############################################################################
# check
###############################################################################

module Dash::Models
  class Check
    attr_reader :name, :status, :body, :host, :cluster, :report_time

    def initialize(yaml, opts)
      @name = yaml.keys.first
      @status = yaml.values.first[:status]
      @body = yaml.values.first[:body]
      @host = opts[:host]
      @cluster = opts[:cluster]
      @report_time = opts[:report_time]
    end

    def match (regexp)
      @name.to_s =~ regexp ||
        @status.to_s =~ regexp ||
        @body.to_s =~ regexp
    end

    def to_s
      "#{name} #{status}:\n#{body}"
    end
  end
end

###############################################################################
