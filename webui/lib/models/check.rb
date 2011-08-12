###############################################################################
# check
###############################################################################

module Dash::Models
  class Check
    attr_reader :name, :status, :body

    def initialize(yaml)
      @name = yaml.keys.first
      @status = yaml.values.first[:status]
      @body = yaml.values.first[:body]
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
